From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 2/7] NetLabel: core network changes
Date: Thu, 22 Jun 2006 02:00:55 -0700 (PDT)
Message-ID: <20060622.020055.115910616.davem@davemloft.net>
References: <20060621194234.979661000@flek.zko.hp.com>
	<20060621200030.880930000@flek.zko.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: redhat-lspp@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	sds@epoch.ncsc.mil, jmorris@redhat.com, sgrubb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63644
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932478AbWFVJA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 05:00:57 -0400
To: paul.moore@hp.com
In-Reply-To: <20060621200030.880930000@flek.zko.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: paul.moore@hp.com
Date: Wed, 21 Jun 2006 15:42:37 -0400

> Index: linux-2.6.17.i686-quilt/include/linux/netlink.h
> ===================================================================
> --- linux-2.6.17.i686-quilt.orig/include/linux/netlink.h
> +++ linux-2.6.17.i686-quilt/include/linux/netlink.h
> @@ -21,6 +21,7 @@
>  #define NETLINK_DNRTMSG		14	/* DECnet routing messages */
>  #define NETLINK_KOBJECT_UEVENT	15	/* Kernel messages to userspace */
>  #define NETLINK_GENERIC		16
> +#define NETLINK_NETLABEL	17	/* Network packet labeling */
>  
>  #define MAX_LINKS 32		

Please use generic netlink.

Jamal posted a very nice document recently on how to use it
properly.  You can read that thread here:

http://marc.theaimsgroup.com/?l=linux-netdev&m=115072450928755&w=2

Thanks.
