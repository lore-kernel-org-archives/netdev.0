From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: 802.3ad bonding brain damaged?
Date: Tue, 09 Aug 2011 13:24:32 +0200
Message-ID: <m3obzyq13j.fsf@ursa.amorsen.dk>
References: <4E3EECF6.90409@cfl.rr.com>
	<1312790234.7020.26.camel@arkology.n2.diac24.net>
	<4E4041B5.5040908@cfl.rr.com> <4E4043AB.1060500@genband.com>
	<4E4047CF.5030705@cfl.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Friesen <chris.friesen@genband.com>,
	David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Phillip Susi <psusi@cfl.rr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.ipvision.dk ([217.195.186.4]:45114 "EHLO
	gate2.ipvision.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254Ab1HILhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 07:37:32 -0400
In-Reply-To: <4E4047CF.5030705@cfl.rr.com> (Phillip Susi's message of "Mon, 08
	Aug 2011 16:32:15 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phillip Susi <psusi@cfl.rr.com> writes:

> Try, sure, but if you can't without seriously affecting performance,
> then having a knob for damn the torpedoes, full speed ahead mode seems
> reasonable.

Packet reordering often affects performance. It can easily be more
costly than losing half the bandwidth of a bundled link.

These days you are even dependent on the NIC firmware for good
performance with TCP for reordered packets -- if the NIC is bad at
handling them, you don't get any performance boost from GRO.

For UDP, applications have to handle it on their own.


/Benny
