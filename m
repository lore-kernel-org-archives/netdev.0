From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH 2/2] 8139too: different style cleanups
Date: Sat, 14 Jun 2008 23:50:37 -0700
Message-ID: <1213512637.11544.36.camel@brick>
References: <4853BB7B.4030905@freemail.hu> <48541173.7040905@freemail.hu>
	 <4854B604.6080900@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Trivial Patch Monkey <trivial@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:30729 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbYFOGuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 02:50:35 -0400
Received: by wa-out-1112.google.com with SMTP id j37so3885291waf.23
        for <netdev@vger.kernel.org>; Sat, 14 Jun 2008 23:50:35 -0700 (PDT)
In-Reply-To: <4854B604.6080900@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-06-15 at 15:56 +0930, David Newall wrote:
> N=C3=A9meth M=C3=A1rton wrote:
> >  #  define DPRINTK(fmt, args...) \
> > -	printk(KERN_DEBUG "%s: " fmt, __FUNCTION__ , ## args)
> > +	printk(KERN_DEBUG "%s: " fmt, __func__ , ## args)
> >  =20
>=20
> Why change __FUNCTION__ to __func__?  I don't even know where __func_=
_
> come from?  Assuming that it isn't totally broken, and I'll believe t=
hat
> it isn't, then would it be compiler-specific?   __FUNCTION__ is stand=
ard
> and that's more than enough reason to prefer that form to any
> non-standard variation.

__FUNCTION__ is gcc-specific, __func__ is C99.

Harvey

