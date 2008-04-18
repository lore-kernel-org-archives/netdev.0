From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Fri, 18 Apr 2008 19:59:58 +0200
Message-ID: <200804181959.58607.mb@bu3sch.de>
References: <bug-10473-10286@http.bugzilla.kernel.org/> <200804181919.17456.mb@bu3sch.de> <9bfa9ae0804181043v60b7c92boef1c025ce04cfe37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Nelson A. de Oliveira" <naoliv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:51051 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758845AbYDRSAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 14:00:22 -0400
In-Reply-To: <9bfa9ae0804181043v60b7c92boef1c025ce04cfe37@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 18 April 2008 19:43:57 Nelson A. de Oliveira wrote:
> Hi!
> 
> On Fri, Apr 18, 2008 at 2:19 PM, Michael Buesch <mb@bu3sch.de> wrote:
> > On Friday 18 April 2008 19:12:34 Nelson A. de Oliveira wrote:
> >  > Anything else that I can do to help, please?
> >
> >  Please apply this patch and send me the messages.
> 
> b44_poll: istat = 0x00000400

Hm, a descriptor error. Smells like my DMA fix actually broke this, damit.
On which architecture are you running?

> I have increased the delay now.  This is the first message that
> appears. It seems that after some time it starts to display the other
> lines from my last email (Pid 4, comm: ksoftirqd/0 ...).

I'm always only interested in the first message of one type :)

-- 
Greetings Michael.
