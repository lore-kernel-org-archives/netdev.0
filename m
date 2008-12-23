From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 1/2] move flow control definitions to mii.h
Date: Tue, 23 Dec 2008 17:47:30 +0000
Message-ID: <1230054450.3402.31.camel@deadeye.i.decadent.org.uk>
References: <1229258301-5073-1-git-send-email-steve.glendinning@smsc.com>
	 <1229258301-5073-2-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:2501 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750955AbYLWRrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 12:47:33 -0500
In-Reply-To: <1229258301-5073-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-12-14 at 12:38 +0000, Steve Glendinning wrote:
[...]
> diff --git a/include/linux/mii.h b/include/linux/mii.h
> index 151b7e0..4a376e0 100644
> --- a/include/linux/mii.h
> +++ b/include/linux/mii.h
> @@ -135,6 +135,10 @@
>  #define LPA_1000FULL            0x0800  /* Link partner 1000BASE-T full duplex */
>  #define LPA_1000HALF            0x0400  /* Link partner 1000BASE-T half duplex */
>  
> +/* Flow control flags */
> +#define FLOW_CTRL_TX		0x01
> +#define FLOW_CTRL_RX		0x02
> +
>  /* This structure is used in all SIOCxMIIxxx ioctl calls */
>  struct mii_ioctl_data {
>  	__u16		phy_id;

How about a FLOW_CTRL_AUTO flag to represent whether auto-negotiation of
FC is enabled (or inversely FLOW_CTRL_FORCE)?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
