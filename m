From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] qlcnic: Enhance ethtool to display board temperature.
Date: Fri, 19 Jul 2013 09:11:28 -0700
Message-ID: <20130719091128.068e5514@nehalam.linuxnetplumber.net>
References: <1374206237-27233-1-git-send-email-himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Himanshu Madhani <himanshu.madhani@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:47170 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760148Ab3GSQLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 12:11:31 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro2so4596074pbb.41
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 09:11:31 -0700 (PDT)
In-Reply-To: <1374206237-27233-1-git-send-email-himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
>  static int
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 38dbafa..2012015 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -101,6 +101,7 @@ struct ethtool_drvinfo {
>  	__u32	testinfo_len;
>  	__u32	eedump_len;	/* Size of data from ETHTOOL_GEEPROM (bytes) */
>  	__u32	regdump_len;	/* Size of data from ETHTOOL_GREGS (bytes) */
> +	__u32	board_temp;     /* board temperature */
>  };

The idea is good but a couple of comments.
1. you can't break userspace ABI for ethtool by adding elements.

2. There already exists a hardware monitoring subsystem in
   Linux and there are applications that use it (like SNMP. If you want this feature to
   be more than a developer toy, then it should use the existing subsystem API's.
