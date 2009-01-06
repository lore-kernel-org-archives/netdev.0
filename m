From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] dm9601: handle corrupt mac address
Date: Tue, 6 Jan 2009 02:28:16 -0800
Message-ID: <200901060228.16744.david-b@pacbell.net>
References: <20090106061414.GA3677@localhost> <20090106082928.GB19690@localhost> <874p0cvnae.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wu Fengguang <wfg@linux.intel.com>, netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp117.sbc.mail.sp1.yahoo.com ([69.147.64.90]:35276 "HELO
	smtp117.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751191AbZAFK2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 05:28:19 -0500
In-Reply-To: <874p0cvnae.fsf@macbook.be.48ers.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 06 January 2009, Peter Korsgaard wrote:
> So what happens if you plug in 2 devices without an EEPROM? Do they
> get the same MAC address? That seems broken.

What happens when you unplug one then re-plug it?  Maybe
someone trips over the USB cable, or it gets an electrical
glitch that evalutes to disconnect/reconnect... It gets
the same address again.  Not particularly broken.

Note that Ethernet was *designed* around using a single
address per host ... I still have XNS docs sitting around
somewhere, that was a fairly significant thing.  One of the
original reasons Ethernet adapter addresses could change
was to make sure that all Ethernet interfaces on a host
would use the same address.

That said ... if it bothers you, that's easy to change
in userspace.  This code has worked this way for around
nine years now; I don't recall any previous complaints.

- Dave


