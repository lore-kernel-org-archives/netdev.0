From: "Artem S. Tashkinov" <t.artem@lycos.com>
Subject: Re: Re: Re: Re: A reliable kernel panic (3.6.2) and system crash
 when visiting a particular website
Date: Sun, 21 Oct 2012 01:57:21 +0000 (GMT)
Message-ID: <1798605268.19162.1350784641831.JavaMail.mail@webmail17>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05>
 <20121020162759.GA12551@liondog.tnic>
 <966148591.30347.1350754909449.JavaMail.mail@webmail08>
 <20121020203227.GC555@elf.ucw.cz> <20121020225849.GA8976@liondog.tnic>
 <1781795634.31179.1350774917965.JavaMail.mail@webmail04>
 <20121021002424.GA16247@liondog.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: pavel@ucw.cz, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org, linux-media@vger.kernel.org,
	linux-usb@vger.kernel.org
To: bp@alien8.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Oct 21, 2012, Borislav Petkov wrote: 
> 
> On Sat, Oct 20, 2012 at 11:15:17PM +0000, Artem S. Tashkinov wrote:
> > You don't get me - I have *no* VirtualBox (or any proprietary) modules
> > running
> 
> Ok, good. We got that out of the way - I wanted to make sure after you
> replied with two other possibilities of the system freezing.
> 
> > - but I can reproduce this problem using *the same system running
> > under* VirtualBox in Windows 7 64.
> 
> That's windoze as host and linux as a guest, correct?

Exactly.

> If so, that's virtualbox's problem, I'd say.

I can reproduce it on my host *alone* as I said in the very first message - never
before I tried to run my Linux in a virtual machine. Please, just forget about
VirtualBox - it has nothing to do with this problem.

> > It's almost definitely either a USB driver bug or video4linux driver
> > bug:
> 
> And you're assuming that because the freeze happens when using your usb
> webcam, correct? And not otherwise?

Yes, like I said earlier - only when I try to access its settings using Adobe Flash the
system crashes/freezes.

> Maybe you can describe in more detail what exactly you're doing so that
> people could try to reproduce your issue.

I don't think many people have the same webcam so it's going to be a problem. It
can be reproduced easily - just open Flash "Settings" in Google Chrome 22. The
crash will occur immediately.

> > I'm CC'ing linux-media and linux-usb mailing lists, the problem is described here:
> > https://lkml.org/lkml/2012/10/20/35
> > https://lkml.org/lkml/2012/10/20/148
> 
> Yes, good idea. Maybe the folks there have some more ideas how to debug
> this.
> 
> I'm leaving in the rest for reference.
> 
> What should be pointed out, though, is that you don't have any more
> random corruptions causing oopses now that virtualbox is gone. The
> freeze below is a whole another issue.

The freeze happens on my *host* Linux PC. For an experiment I decided to
check if I could reproduce the freeze under a virtual machine - it turns out the
Linux kernel running under it also freezes.

Artem
