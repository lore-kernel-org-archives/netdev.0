From: bert hubert <bert.hubert@netherlabs.nl>
Subject: sendfile()? Re: SO_LINGER dead: I get an immediate RST on 2.6.24?
Date: Sun, 11 Jan 2009 23:45:43 +0100
Message-ID: <20090111224541.GA10848@outpost.ds9a.nl>
References: <20090111212303.GA8612@outpost.ds9a.nl> <175f5a0f0901111408s7905e5d9l2155b841f1ac054d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "H. Willstrand" <h.willstrand@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([85.17.220.215]:40058 "EHLO outpost.ds9a.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751409AbZAKWpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 17:45:34 -0500
Content-Disposition: inline
In-Reply-To: <175f5a0f0901111408s7905e5d9l2155b841f1ac054d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 11:08:16PM +0100, H. Willstrand wrote:
> > Is SO_LINGER a NOOP? Does it still do anything?
> This is the correct behavior according to RFC 2525, see section 2.17
> (there are an example).

Ah - very good, thank you. I'm trying to gather as much information as I can
before writing this all up. This should save netdev & the linux kernel
community a lot of email!

Is there any way to make sure there is no pending output data, so one can
safely call close(), and not get an RST-situation? 

Let me put it more succinctly. What I would very much like to have is what
Linux sendfile() offers in practice.

It appears that if one asks sendfile() to transmit a million bytes, it will
only return when the ACK for the millionth byte is in.

I know that TCP will never be fully fully reliable, but I would love to have
a way to know that the millionth byte was ACKed, or alternatively, that an
error prevented that.

>From what I've read so far, I think the POSIX functions don't offer this.
But does Linux? sendfile appears to get it right..

Thanks.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
