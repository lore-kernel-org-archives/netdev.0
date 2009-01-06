From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] dm9601: handle corrupt mac address
Date: Tue, 06 Jan 2009 11:56:16 +0100
Message-ID: <87vdssu2i7.fsf@macbook.be.48ers.dk>
References: <20090106061414.GA3677@localhost>
	<20090106082928.GB19690@localhost>
	<874p0cvnae.fsf@macbook.be.48ers.dk>
	<200901060228.16744.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wu Fengguang <wfg@linux.intel.com>, netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:51424 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbZAFK4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 05:56:21 -0500
Received: by ewy10 with SMTP id 10so8366449ewy.13
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2009 02:56:19 -0800 (PST)
In-Reply-To: <200901060228.16744.david-b@pacbell.net> (David Brownell's message of "Tue\, 6 Jan 2009 02\:28\:16 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "David" == David Brownell <david-b@pacbell.net> writes:

 David> On Tuesday 06 January 2009, Peter Korsgaard wrote:
 >> So what happens if you plug in 2 devices without an EEPROM? Do they
 >> get the same MAC address? That seems broken.

 David> What happens when you unplug one then re-plug it?  Maybe
 David> someone trips over the USB cable, or it gets an electrical
 David> glitch that evalutes to disconnect/reconnect... It gets
 David> the same address again.  Not particularly broken.

 David> Note that Ethernet was *designed* around using a single
 David> address per host ... I still have XNS docs sitting around
 David> somewhere, that was a fairly significant thing.  One of the
 David> original reasons Ethernet adapter addresses could change
 David> was to make sure that all Ethernet interfaces on a host
 David> would use the same address.

 David> That said ... if it bothers you, that's easy to change
 David> in userspace.  This code has worked this way for around
 David> nine years now; I don't recall any previous complaints.

Ok, I don't feel particular strongly about it, just found it odd.

-- 
Bye, Peter Korsgaard
