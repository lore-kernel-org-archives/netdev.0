From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/11] inet_diag: Partly rename inet_ to sock_
Date: Tue, 6 Dec 2011 10:24:47 -0800
Message-ID: <20111206102447.25cc60f4@nehalam.linuxnetplumber.net>
References: <4EDE573A.6040607@parallels.com>
	<4EDE575B.3010507@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48477 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752521Ab1LFSYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 13:24:50 -0500
In-Reply-To: <4EDE575B.3010507@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 06 Dec 2011 21:56:43 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> diff --git a/include/linux/netlink.h b/include/linux/netlink.h
> index 8374d29..9827ebf 100644
> --- a/include/linux/netlink.h
> +++ b/include/linux/netlink.h
> @@ -8,7 +8,7 @@
>  #define NETLINK_UNUSED		1	/* Unused number				*/
>  #define NETLINK_USERSOCK	2	/* Reserved for user mode socket protocols 	*/
>  #define NETLINK_FIREWALL	3	/* Firewalling hook				*/
> -#define NETLINK_INET_DIAG	4	/* INET socket monitoring			*/
> +#define NETLINK_SOCK_DIAG	4	/* socket monitoring				*/
>  #define NETLINK_NFLOG		5	/* netfilter/iptables ULOG */
>  #define NETLINK_XFRM		6	/* ipsec */
>  #define NETLINK_SELINUX		7	/* SELinux event notifications */

This is a header file that is stripped and exported by other
tools. You can add new entries but need to keep existing define's
to avoid breaking source compatibility.
