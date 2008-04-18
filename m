From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Fri, 18 Apr 2008 17:32:48 +0200
Message-ID: <200804181732.48546.mb@bu3sch.de>
References: <bug-10473-10286@http.bugzilla.kernel.org/> <200804181606.34853.mb@bu3sch.de> <9bfa9ae0804180823o1c3213ccj6ac1ab19b0b5cb94@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Nelson A. de Oliveira" <naoliv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:33217 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbYDRPdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 11:33:12 -0400
In-Reply-To: <9bfa9ae0804180823o1c3213ccj6ac1ab19b0b5cb94@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 18 April 2008 17:23:06 Nelson A. de Oliveira wrote:
> Hi!
> 
> On Fri, Apr 18, 2008 at 11:06 AM, Michael Buesch <mb@bu3sch.de> wrote:
> >  > > While booting the new 2.6.25 Kernel, it enters an infinite looping displaying
> >  > > "b44: eth0: powering down PHY".
> >  > > The system isn't freezed as magick SysRq keys works, but it just stay
> >  > > displaying those messages. I am unable to dump any information using SysRq,
> >  > > however (as the b44(...) messages are too fast).
> >  > >
> >  > > I will attach lspci output and my .config
> >  > >
> >  >
> >  > Apparently a regression.
> >
> >  Can you add a dump_stack() call to the b44_halt() function and post the resulting logs?
> 
> What I get is:
> 
> Pid: 4, comm: ksoftirqd/0 Tainted: GF 2.6.25-naoliv1 #2
> [<f8992420>] [<b0231ffd>] [<b02380b9>] [<b011ed60>] [<b01060f2>]
> [<b011f059>] [<b011efe1>] [<b01297c8>] [<b0129790>] [<b010473f>]

Ehm, please enable CONFIG_KALLSYMS.

> BTW, is it a way to "pause" the messages after dump_stack()?

mdelay(1000) will delay one second. But it will kill the system, basically.

-- 
Greetings Michael.
