From: "Nelson A. de Oliveira" <naoliv@gmail.com>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Fri, 18 Apr 2008 17:38:30 -0300
Message-ID: <9bfa9ae0804181338q4a53fffdhe1833441794aed7@mail.gmail.com>
References: <bug-10473-10286@http.bugzilla.kernel.org/>
	 <200804182018.52753.mb@bu3sch.de>
	 <9bfa9ae0804181202o601e7e86p135547ce802db88d@mail.gmail.com>
	 <200804182119.16195.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:26571 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbYDRUio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 16:38:44 -0400
Received: by yw-out-2324.google.com with SMTP id 5so496228ywb.1
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2008 13:38:31 -0700 (PDT)
In-Reply-To: <200804182119.16195.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Fri, Apr 18, 2008 at 4:19 PM, Michael Buesch <mb@bu3sch.de> wrote:
>  Well. 2.6.24 didn't have this message. But it could still have the actual
>  bug, of course. So can you try applying my printk patch to a broken 2.6.24
>  kernel and see whether it triggers the message or not? Under normal
>  circumstances this codepath should never trigger.

No b44_poll message printed when using your patch on 2.6.24, 2.6.23 and 2.6.21.

>  Can you try bisecting the bug? Yeah, I know about the lwn article [1] that
>  says bisecting is baaaaaad (tm), but my opinion is different. :)
>  It's an excellent tool for efficiently finding patches that caused bugs.
>  But take care to really check whether device _works_ or not. Just looking
>  at the actual "powering down PHY" will _not_ be enough, as that was only
>  recently added, as I said.

Sure. I will do this when I arrive at home (Can you point me to some
URL to read and do the bisections, please?).
What I saw with 2.6.24, 2.6.23 and 2.6.21 is that the interface seems
to be up, getting an IP via DHCP (I can ping from another machine),
but it stays waiting for something after printing

b44: eth0: Link is up at 100 Mbps, full duplex.
b44: eth0: Flow control is off for TX and off for RX.

Thank you!

Best regards,
Nelson
