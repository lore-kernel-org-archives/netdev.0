From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [git patches] 2.6.x net driver updates
Date: Fri, 13 Jan 2006 18:56:12 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0601131844230.30994@scrub.home>
References: <20060112221322.GA25470@havoc.gtf.org> <Pine.LNX.4.64.0601121423120.3535@g5.osdl.org>
 <20060112143938.5cf7d6a5.akpm@osdl.org> <Pine.LNX.4.64.0601121444030.3535@g5.osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422757AbWAMR4q@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0601121444030.3535@g5.osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, 12 Jan 2006, Linus Torvalds wrote:

> > Yes, I think that's much more Aunt-Nellie-friendly, but Roman considers it
> > abuse of the Kconfig system in ways which I never completely understood?
> 
> Hmm. If Roman dislikes it, he must dislike the fact that we already do 
> exactly this for a ton of different things. There's something like 2000+ 
> "select" statements in the kernel Kconfig tree, and just grepping for 
> "select.*CRYPTO" gets 52 hits..

The basic problem is that it overrides any other dependencies and it makes 
easy to screw them up.
The basic rule should be to use select only to include library 
functionality, which is mostly independent and has no other dependencies.
Selecting larger subsystem, which may require more configuration itself, 
should be avoided.

bye, Roman
