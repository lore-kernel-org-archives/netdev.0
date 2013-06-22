From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next 5/8] qlcnic: Cleanup of structure
 qlcnic_hardware_context
Date: Sat, 22 Jun 2013 03:53:48 -0700
Message-ID: <1371898428.3137.5.camel@joe-AO722>
References: <1371888727-16422-1-git-send-email-jitendra.kalsaria@qlogic.com>
	 <1371888727-16422-6-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sony.chacko@qlogic.com, shahed.shaikh@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Pratik Pujar <pratik.pujar@qlogic.com>
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37205 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751965Ab3FVKxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jun 2013 06:53:49 -0400
In-Reply-To: <1371888727-16422-6-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-22 at 04:12 -0400, Jitendra Kalsaria wrote:
> From: Pratik Pujar <pratik.pujar@qlogic.com>

This isn't really a cleanup.
It's allowing more capabilities.

> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
[]
> @@ -449,7 +449,7 @@ struct qlcnic_hardware_context {
>  	u16 max_pci_func;
>  
>  	u32 capabilities;
> -	u32 capabilities2;
> +	u32 extra_capability[3];

Also, it looks like it's used as a bitfield.

I suggest instead using an array of ulongs and
something like tg3's use of tg3_flag_set|tg3_flag_clear.
