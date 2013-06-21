From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/8] qlcnic: Secondary unicast MAC address
 support.
Date: Fri, 21 Jun 2013 10:10:09 -0700
Message-ID: <1371834609.19215.47.camel@joe-AO722>
References: <1371832261-18930-1-git-send-email-jitendra.kalsaria@qlogic.com>
	 <1371832261-18930-3-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sony.chacko@qlogic.com, shahed.shaikh@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37097 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1423404Ab3FURKK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 13:10:10 -0400
In-Reply-To: <1371832261-18930-3-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-21 at 12:30 -0400, Jitendra Kalsaria wrote:
> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> 
> Add support for configuring secondary unicast address which
> will use existing HW filters to store all the unicast MAC
> addresses and prevent device going into promiscuous mode.

[]

> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
[]
> @@ -421,6 +421,7 @@ struct qlcnic_hardware_context {
> +	u8 max_uc_count;

> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
[]
> +#define QLC_83XX_MAX_UC_COUNT			4096

> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
[]
> +#define QLCNIC_MAX_UC_COUNT		512

These #defines don't seem right.
There's no way to fit these values in a u8.
