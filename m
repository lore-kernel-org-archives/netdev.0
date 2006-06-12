From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH] wan/sdla section fixes
Date: Mon, 12 Jun 2006 11:05:23 -0700
Message-ID: <20060612110523.300a3420.rdunlap@xenotime.net>
References: <20060608203616.16796ec3.rdunlap@xenotime.net>
	<m3d5de461t.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mike.mclagan@linux.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:58793 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1750801AbWFLSCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 14:02:35 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Mon, 12 Jun 2006 11:02:35 -0700
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m3d5de461t.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Jun 2006 19:50:22 +0200 Krzysztof Halasa wrote:

> Hi,
> 
> "Randy.Dunlap" <rdunlap@xenotime.net> writes:
> 
> > Priority: tossup.
> > netdev->set_config can be called at any time, so these references
> > to __initdata would be a real problem.
> > However, problem has not been observed AFAIK.
> >
> > Fix section mismatch warnings:
> > WARNING: drivers/net/wan/sdla.o - Section mismatch: reference to .init.data: from .text between 'sdla_set_config' (at offset 0x1b8e) and 'sdla_stats'
> > WARNING: drivers/net/wan/sdla.o - Section mismatch: reference to .init.data: from .text between 'sdla_set_config' (at offset 0x1e76) and 'sdla_stats'
> 
> Is sdla.c still in use? I remember someone mentioned that Sangoma
> drivers are now outside the kernel but I don't know how do they
> relate to sdla.c and friend(s).

No idea.

> >  static const char* version = "SDLA driver v0.30, 12 Sep 1996,
> > mike.mclagan@linux.org";
> 
> 1996 doesn't look encouraging but it may be misleading.

Yep.  You could ignore it :) or rm drivers/net/wan/slda*  :)

---
~Randy
