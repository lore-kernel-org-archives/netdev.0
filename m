From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Mon, 23 Nov 2015 09:20:39 +1030
Message-ID: <20151122225039.GE2957@marvin.atrad.com.au>
References: <20130309064647.GC4984@marvin.atrad.com.au>
 <20130311000216.GA31808@zoreil.com>
 <20130405001526.GC19253@marvin.atrad.com.au>
 <20151117015605.GI22941@marvin.atrad.com.au>
 <20151117232108.GC3362@electric-eye.fr.zoreil.com>
 <20151118050919.GR25216@marvin.atrad.com.au>
 <20151119005608.GB4882@electric-eye.fr.zoreil.com>
 <20151120024616.GL7136@marvin.atrad.com.au>
 <20151120224534.GA25025@electric-eye.fr.zoreil.com>
 <20151121223627.GA3493@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:43231 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbbKVWut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 17:50:49 -0500
Content-Disposition: inline
In-Reply-To: <20151121223627.GA3493@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 21, 2015 at 11:36:27PM +0100, Francois Romieu wrote:
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
> 
> If you can crash your system at will, you may apply the patch below to
> da78dbff2e05630921c551dbbc70a4b7981a8fff ("r8169: remove work from irq
> handler.") parent (aka 1e874e041fc7c222cbd85b20c4406070be1f687a) and
> build it in a current tree (say 4.2).

No problem crashing the machine at present.  It is an internal test machine
which I am using to chase this issue at present.

As I understand the above you would like me to get r8169.c from
1e874e041fc7c222cbd85b20c4406070be1f687a, apply the patch, drop it into
kernel 4.2 and run with that.  That's fine.

I'm a little confused though as to which patch you want me to apply.  There
was an inline patch against r8169.c in your message, and then there was
another patch to r8169.c in the form of an attachment.  Both patches removed
the include of asm/system.h but the rest of the content differs.  Did you
want each tried in turn?  Apologies if I'm missing something obvious.

> How much memory and CPU may I rely on in your test computer ?

Since the problem can be triggered without me having to run the full data
acquisition system, the machine is basically unloaded (it doesn't take many
resources to send/receive 6 udp packets at a time :-) ).  The CPU is an
i7-860 CPU at 2.8 GHz, with 4 GB of RAM fitted and 8 GB swap.  The kernel
and userspace are 32-bit, so we have the usual 3 GB per-process memory
limit.

Regards
  jonathan
