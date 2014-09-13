From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/7] net: Changes to ip_tunnel to support
 foo-over-udp encapsulation
Date: Sat, 13 Sep 2014 13:09:55 -0400 (EDT)
Message-ID: <20140913.130955.2175593212041609028.davem@davemloft.net>
References: <1410466056-30239-1-git-send-email-therbert@google.com>
	<1410466056-30239-5-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759AbaIMRJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 13:09:57 -0400
In-Reply-To: <1410466056-30239-5-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 11 Sep 2014 13:07:33 -0700

> @@ -17,6 +17,10 @@
>  #define SIOCADD6RD      (SIOCDEVPRIVATE + 9)
>  #define SIOCDEL6RD      (SIOCDEVPRIVATE + 10)
>  #define SIOCCHG6RD      (SIOCDEVPRIVATE + 11)
> +#define SIOCGETTUNENCAP (SIOCDEVPRIVATE + 12)
> +#define SIOCADDTUNENCAP (SIOCDEVPRIVATE + 13)
> +#define SIOCDELTUNENCAP (SIOCDEVPRIVATE + 14)
> +#define SIOCCHGTUNENCAP (SIOCDEVPRIVATE + 15)
>  
>  #define GRE_CSUM	__cpu_to_be16(0x8000)
>  #define GRE_ROUTING	__cpu_to_be16(0x4000)

Let's not extend the ioctls and just add the netlink parts,
thanks.
