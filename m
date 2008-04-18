From: "Nelson A. de Oliveira" <naoliv@gmail.com>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Fri, 18 Apr 2008 16:02:37 -0300
Message-ID: <9bfa9ae0804181202o601e7e86p135547ce802db88d@mail.gmail.com>
References: <bug-10473-10286@http.bugzilla.kernel.org/>
	 <200804181959.58607.mb@bu3sch.de>
	 <9bfa9ae0804181109h711d0c48v9b2d3319cfca7657@mail.gmail.com>
	 <200804182018.52753.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:16552 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760708AbYDRTJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 15:09:54 -0400
Received: by yw-out-2324.google.com with SMTP id 5so470897ywb.1
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2008 12:09:32 -0700 (PDT)
In-Reply-To: <200804182018.52753.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Fri, Apr 18, 2008 at 3:18 PM, Michael Buesch <mb@bu3sch.de> wrote:
> On Friday 18 April 2008 20:09:36 Nelson A. de Oliveira wrote:
>  > On Fri, Apr 18, 2008 at 2:59 PM, Michael Buesch <mb@bu3sch.de> wrote:
>  > >  > b44_poll: istat = 0x00000400
>  > >
>  > >  Hm, a descriptor error. Smells like my DMA fix actually broke this, damit.
>  > >  On which architecture are you running?
>  >
>  > i386 here.
>
>  Hm, I tested my patch on i386.
>  So I'm not sure what's going on, actually. And the patch was pretty
>  trivial and I really can't find a bug in it.
>  So you say 2.6.24 was still working?

Strange... compiled 2.6.24.4, 2.6.24 and 2.6.23 here and they are all
stopping with this:

b44: eth0: Link is up at 100 Mbps, full duplex.
b44: eth0: Flow control is off for TX and off for RX.

And it seems to keep waiting for something. The system isn't freezed
(as CTRL+ALT+DEL kills the running processes and correctly reboots the
machine).

With Debian's 2.6.24.4 it is working.
With vanilla 2.6.25 and my config it just enters an infinite loop of
"b44: eth0: powering down PHY".
Can different GCC versions cause this? Can a bad .config file cause
things like that? (I am using this .config for a long time and it has
always been working correctly, at least until now)

Thank you!

Best regards,
Nelson
