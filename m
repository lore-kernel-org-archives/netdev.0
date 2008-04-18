From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Fri, 18 Apr 2008 20:18:52 +0200
Message-ID: <200804182018.52753.mb@bu3sch.de>
References: <bug-10473-10286@http.bugzilla.kernel.org/> <200804181959.58607.mb@bu3sch.de> <9bfa9ae0804181109h711d0c48v9b2d3319cfca7657@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Nelson A. de Oliveira" <naoliv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:53238 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760288AbYDRSTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 14:19:16 -0400
In-Reply-To: <9bfa9ae0804181109h711d0c48v9b2d3319cfca7657@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 18 April 2008 20:09:36 Nelson A. de Oliveira wrote:
> On Fri, Apr 18, 2008 at 2:59 PM, Michael Buesch <mb@bu3sch.de> wrote:
> >  > b44_poll: istat = 0x00000400
> >
> >  Hm, a descriptor error. Smells like my DMA fix actually broke this, damit.
> >  On which architecture are you running?
> 
> i386 here.

Hm, I tested my patch on i386.
So I'm not sure what's going on, actually. And the patch was pretty
trivial and I really can't find a bug in it.
So you say 2.6.24 was still working?

-- 
Greetings Michael.
