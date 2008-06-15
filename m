From: David Newall <davidn@davidnewall.com>
Subject: Re: [PATCH 2/2] 8139too: different style cleanups
Date: Sun, 15 Jun 2008 15:56:12 +0930
Message-ID: <4854B604.6080900@davidnewall.com>
References: <4853BB7B.4030905@freemail.hu> <48541173.7040905@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Trivial Patch Monkey <trivial@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?TsOpbWV0aCBNw6FydG9u?= <nm127@freemail.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth7959.sa.adsl.internode.on.net ([150.101.82.22]:44216 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751436AbYFOG0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 02:26:17 -0400
In-Reply-To: <48541173.7040905@freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

N=C3=A9meth M=C3=A1rton wrote:
>  #  define DPRINTK(fmt, args...) \
> -	printk(KERN_DEBUG "%s: " fmt, __FUNCTION__ , ## args)
> +	printk(KERN_DEBUG "%s: " fmt, __func__ , ## args)
>  =20

Why change __FUNCTION__ to __func__?  I don't even know where __func__
come from?  Assuming that it isn't totally broken, and I'll believe tha=
t
it isn't, then would it be compiler-specific?   __FUNCTION__ is standar=
d
and that's more than enough reason to prefer that form to any
non-standard variation.


Yes to the following; no to all the rest:

> -#define RTL8139_CAPS	HAS_CHIP_XCVR|HAS_LNK_CHNG
> +#define RTL8139_CAPS	(HAS_CHIP_XCVR|HAS_LNK_CHNG)

