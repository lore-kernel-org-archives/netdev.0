From: Pavel Machek <pavel@ucw.cz>
Subject: Re: RFC: A reduced Linux network stack for small systems
Date: Fri, 9 May 2014 09:38:48 +0200
Message-ID: <20140509073847.GD4965@xo-6d-61-c0.localdomain>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
 <CAFLxGvww8t-PpuS3B=dFvn8k3xBydk3CgA=qoLyEbkKJZJ0xhQ@mail.gmail.com>
 <1399383246.8767.99.camel@empanada>
 <CAADnVQLYiNfXRrXc=VZkGEFDbNhF63AzPg6Gyu6P1SF=6AiO7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Zanussi <tom.zanussi@linux.intel.com>,
	Richard Weinberger <richard.weinberger@gmail.com>,
	Andi Kleen <andi@firstfloor.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAADnVQLYiNfXRrXc=VZkGEFDbNhF63AzPg6Gyu6P1SF=6AiO7g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > wants to build it and try it out:
> >
> > https://github.com/tzanussi/meta-galileo/blob/daisy/meta-galileo/README
> >
> > It's very much a work-in-progress with a lot of rough edges, but it is a
> > fully functional system on real hardware (Galileo board/Quark processor)
> > with a usable shell (ps too!) and web server running on a kernel with
> > native networking and ~ 750k text size.
> 
> Intel Galileo datasheet says:
> - 400MHz 32bit Intel
> - 512 KBytes of on-die embedded SRAM
> - 256 MByte DRAM, enabled by the firmware by default
> 
> where did 2-4Mbyte restriction come from?
> 
> Anyway, with all these hacks you get a half functional kernel with "a
> lot of rough edges"
> that is likely working only for the given very limited set of applications.
> Kernel function profiling can potentially achieve the same thing.
> Profile the kernel with the set of apps and then prune all cold
> functions out of kernel.

That does not really work, right? As soon attacker triggers some error path
you did not trigger in testing, your machine dies.

That no longer qualifies as functional kernel.

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
