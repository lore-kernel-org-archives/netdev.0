From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 1/2] Prepare the tree for un-inlined jhash.
Date: Thu, 25 Nov 2010 14:57:34 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1011251454430.996@blackhole.kfki.hu>
References: <1290690908-794-1-git-send-email-kadlec@blackhole.kfki.hu> <1290690908-794-2-git-send-email-kadlec@blackhole.kfki.hu> <alpine.LNX.2.01.1011251439160.21752@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1011251439160.21752@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Nov 2010, Jan Engelhardt wrote:

> On Thursday 2010-11-25 14:15, Jozsef Kadlecsik wrote:
> 
> >jhash is widely used in the kernel and because the functions
> >are inlined, the cost in size is significant. Also, the new jhash
> >functions are slightly larger than the previous ones so better un-inline.
> >As a preparation step, the calls to the internal macros are replaced
> >with the plain jhash function calls.
> 
> Do you have a non-normative allyesconfig/allmodconfig build whose 
> size(1) you can run on, to show approximately just how much it differs?

In the cover mail I referred the link to the message from Ilpo Jarvinen: 
"I once looked into inlining cost and jhash functions were among the most 
wasteful (kernel-wide). Multiple jhash bodies were 100+ bytes, and the 
overall cost was 10k+."

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
