From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: 'embedded people' and the 'embedded world' (was: Re: [RFC patch] driver for the Opencores Ethernet Controller)
Date: Tue, 5 Dec 2006 01:29:36 +0100
Message-ID: <20061205002936.GA23400@xi.wantstofly.org>
References: <200612041801.kB4I11F4018165@oogie-boogie.ics.uci.edu> <20061204180734.GA21561@xi.wantstofly.org> <200612041827.kB4IRqrW019090@oogie-boogie.ics.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:37894 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967886AbWLEA3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 19:29:39 -0500
To: Dan Nicolaescu <dann@ics.uci.edu>
Content-Disposition: inline
In-Reply-To: <200612041827.kB4IRqrW019090@oogie-boogie.ics.uci.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 04, 2006 at 10:27:52AM -0800, Dan Nicolaescu wrote:

> I didn't know about "platform drivers" before your mail. I guess I
> could convert it to that if that is the right thing to do. 
> (It might be an overkill given that the device is kind of simple and
> embedded people prefer small code...)

BTW (and this is not specifically directed to you.)

I count myself as an 'embedded person', having contributed a thing or
two to the Linux ARM kernel port and doing most of my Linux hacking on
ARM platforms, but I certainly don't share your opinion w.r.t. what
'embedded people' want or don't want.

Nor do I share any of the opinions of most 'embedded people' who
proclaim to be representing 'the embedded world' to 'the outside world',
the opinions that have gotten the embedded crowd the bad reputation
that we have gotten over the years.

- "We can't use existing kernel infrastructure because we are special."

- "Let's save 8 bytes and 2 cycles in a slow path by throwing all
  established and sane kernel design principles out of the window."

- "If we code this in a really ugly, unmaintainable, incompatible,
  incomprehensible way, we can save 3 cycles in the slow path.  Let's
  do it."

- "All our code lives in a separately maintained tree, and everyone
  wanting to use Linux on our CPUs will have to use our 'Cirrus Logic
  Linux 2.6.8.1 version 1.3.2' release[*].  We can't be bothered to
  merge with upstream because we are special."

- "There's nothing wrong with a function having 500 lines."

- "We are using 2.4.6 because it is more stable than all that
  newfangled 2.6 stuff."

- etc.

It does piss me off from time to time that these people are out there,
and that they claim to be speaking in my name when they spout their
nonsense.

For all the 'non-embedded' folks out there: the next time you hear
someone claiming to be representing 'the embedded world', please take
whatever they say with a bag of salt.


[*] Seriously, I didn't make this up.
