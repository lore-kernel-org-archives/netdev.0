From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Thu, 24 Oct 2002 15:41:59 -0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200210241249.g9OCnOp09750@Port.imtp.ilyichevsk.odessa.ua>
References: <200210231218.18733.roy@karlsbakk.net> <200210241129.g9OBTpp09266@Port.imtp.ilyichevsk.odessa.ua> <20021024125030.A7529@flint.arm.linux.org.uk>
Reply-To: vda@port.imtp.ilyichevsk.odessa.ua
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: Roy Sigurd Karlsbakk <roy@karlsbakk.net>, netdev@oss.sgi.com,
	Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Russell King <rmk@arm.linux.org.uk>
In-Reply-To: <20021024125030.A7529@flint.arm.linux.org.uk>
List-Id: netdev.vger.kernel.org

On 24 October 2002 09:50, Russell King wrote:
> On Thu, Oct 24, 2002 at 02:22:25PM -0200, Denis Vlasenko wrote:
> > Please delete memory.o, rerun make bzImage, capture gcc
> > command used for compiling memory.c, modify it:
> >
> > gcc ... -o memory.o  ->  gcc ... -S -o memory.s ...
>
> Have you tried make mm/memory.s ?

No ;) but I have a feeling it will produce that file ;)))

I'm experimenting with different csum_ routines in userspace now.
--
vda
