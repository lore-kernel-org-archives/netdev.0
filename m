From: Horst von Brand <vonbrand@inf.utfsm.cl>
Subject: Re: [git patch] urgent e1000 fix
Date: Fri, 24 Jun 2005 11:11:28 -0400
Message-ID: <200506241511.j5OFBSn9013742@laptop11.inf.utfsm.cl>
References: <vda@ilport.com.ua>
Cc: Linus Torvalds <torvalds@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	David Lang <david.lang@digitalinsight.com>,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262991AbVFXPOC@vger.kernel.org>
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: Message from Denis Vlasenko <vda@ilport.com.ua>
   of "Fri, 24 Jun 2005 09:49:05 +0300." <200506240949.05620.vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis Vlasenko <vda@ilport.com.ua> wrote:
> On Friday 24 June 2005 02:33, Linus Torvalds wrote:
> > To actually allow real fuzz or to allow real whitespace differences in the
> > patch data itself is a _much_ bigger issue than this trivial patch
> > corruption, and I'd prefer to avoid going there if at all possible.
> 
> How about automatic stripping of _trailing_ whitespace on all incoming
> patches? IIRC no file type (C, sh, Makefile, you name it) depends on
> conservation of it, thus it's 100% safe.

Works iff the patched code is similarly mangled first... I can hear a
distant howling on LKML on the bare thought of proposing this.

You also can't assume that spaces at the end of lines make no difference
for all uses people might want to put git to.
-- 
Dr. Horst H. von Brand                   User #22616 counter.li.org
Departamento de Informatica                     Fono: +56 32 654431
Universidad Tecnica Federico Santa Maria              +56 32 654239
Casilla 110-V, Valparaiso, Chile                Fax:  +56 32 797513
