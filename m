From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sat, 23 May 2009 12:46:13 -0400
Message-ID: <1243097173.4217.7.camel@obelisk.thedillows.org>
References: <200903041828.49972.m.bueker@berlin.de>
	 <4A0C7443.1010000@googlemail.com>
	 <1243042174.3580.23.camel@obelisk.thedillows.org>
	 <200905231124.28925.mb@bu3sch.de>  <4A1809B0.3030109@googlemail.com>
	 <1243090308.4217.6.camel@obelisk.thedillows.org>
	 <4A182066.9030201@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?ISO-8859-1?Q?B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Riepe <michael.riepe@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757028AbZEWQqZ@vger.kernel.org>
In-Reply-To: <4A182066.9030201@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2009-05-23 at 18:12 +0200, Michael Riepe wrote:
> If I use two connections (iperf -P2) and nail iperf to both threads of a
> single core with taskset (the program is multi-threaded, just in case
> you wonder), I get this:
> 
> CPU 0+2:  0.0-60.0 sec  4.65 GBytes    665 Mbits/sec
> CPU 1+3:  0.0-60.0 sec  6.43 GBytes    920 Mbits/sec
> 
> That's quite a difference, isn't it?
> 
> Now I wonder what CPU 0 is doing...

Where does /proc/interrupts say the irqs are going?
