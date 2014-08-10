From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH] ipv6: do not add link-local address if one already
 exists
Date: Sun, 10 Aug 2014 22:37:12 +0200
Message-ID: <1407703032.2161.22.camel@localhost>
References: <d630f87aa617098553c3a3361fcf50aa@mail.marples.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"David S. Miller\" <davem@davemloft.net>, Alexey Kuznetsov "
	 "<kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, "
	 Patrick McHardy <kaber@trash.net>
To: Roy Marples <roy@marples.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3830 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751173AbaHJUhV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Aug 2014 16:37:21 -0400
In-Reply-To: <d630f87aa617098553c3a3361fcf50aa@mail.marples.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On So, 2014-08-10 at 19:56 +0000, Roy Marples wrote:
> Currently the kernel will always add an IPv6 link-local address
> based on the hardware address when the interface is brought up.
> This is probably based on the assumption that userland would
> never add one before the interface is brought up.
> 
> However, one at least one userland application (dhcpcd) does this so
> it can implement RFC7217 which can be used for link-local addresses
> as well.
> 
> Attached is a patch which checks to see if a link-local address exists
> before indiscriminately adding one.

Please have a look at:
https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=bc91b0f07ada5535427373a4e2050877bcc12218

This was recently implemented just for this specific case.

Bye,
Hannes
