From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: gro: support sit protocol
Date: Tue, 03 Nov 2015 05:07:33 -0800
Message-ID: <1446556053.23275.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
	 <1445306641.30896.42.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1445312417.30896.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <19837690.PaPkekjCr9@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Jerry Chu <hkchu@google.com>,
	JesseGross <jesse@nicira.com>, Tom Herbert <tom@herbertland.com>,
	netdev <netdev@vger.kernel.org>, kernel-team@fb.com,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34384 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbbKCNHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 08:07:35 -0500
Received: by padhx2 with SMTP id hx2so10591514pad.1
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 05:07:35 -0800 (PST)
In-Reply-To: <19837690.PaPkekjCr9@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-03 at 13:57 +0100, Wolfgang Walter wrote:
> Am Montag, 19. Oktober 2015, 20:40:17 schrieb Eric Dumazet:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Tom Herbert added SIT support to GRO with commit
> > 19424e052fb4 ("sit: Add gro callbacks to sit_offload"),
> > later reverted by Herbert Xu.
> > 
> > The problem came because Tom patch was building GRO
> > packets without proper meta data : If packets were locally
> > delivered, we would not care.
> > 
> > But if packets needed to be forwarded, GSO engine was not
> > able to segment individual segments.
> > 
> > With the following patch, we correctly set skb->encapsulation
> > and inner network header. We also update gso_type.
> > 
> 
> I'm running 4.1.11 / 4.1.12 with this patch on top now since over a week. 
> ISATAP works fine.

Perfect ! thanks a lot for testing !
