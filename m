From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] netlink: specify netlink packet direction
 for nlmon
Date: Sun, 22 Dec 2013 18:56:28 -0500 (EST)
Message-ID: <20131222.185628.593979257362137672.davem@davemloft.net>
References: <1387416579-3098-1-git-send-email-dborkman@redhat.com>
	<1387416579-3098-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darkjames-ws@darkjames.pl
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53303 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756197Ab3LVX4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:56:30 -0500
In-Reply-To: <1387416579-3098-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 19 Dec 2013 02:29:39 +0100

> @@ -29,6 +29,9 @@ struct sockaddr_ll {
>  /* These ones are invisible by user level */
>  #define PACKET_LOOPBACK		5		/* MC/BRD frame looped back */
>  #define PACKET_FASTROUTE	6		/* Fastrouted frame	*/
> +/* These ones are for nlmon devices */
> +#define PACKET_USER		0		/* To user space */
> +#define PACKET_KERNEL		1		/* To kernel space */

I know it is tempting to do so, but please do not reuse values
like this.

THanks.
