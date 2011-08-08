From: Phillip Susi <psusi@cfl.rr.com>
Subject: Re: 802.3ad bonding brain damaged?
Date: Mon, 08 Aug 2011 16:32:15 -0400
Message-ID: <4E4047CF.5030705@cfl.rr.com>
References: <4E3EECF6.90409@cfl.rr.com> <1312790234.7020.26.camel@arkology.n2.diac24.net> <4E4041B5.5040908@cfl.rr.com> <4E4043AB.1060500@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.123]:53057 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079Ab1HHUcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 16:32:16 -0400
In-Reply-To: <4E4043AB.1060500@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/8/2011 4:14 PM, Chris Friesen wrote:
> Bonding doesn't know about "higher level protocols". Also, assuming that
> higher level protocols already deal with reordering can be dangerous.
> I've dealt with network protocols and apps that assumed there would be
> no reordering because at the time they were written they used
> point-to-point links. They actually work fairly well with single links,
> so it would be reasonable to try and keep them working with bonded links.

Try, sure, but if you can't without seriously affecting performance, 
then having a knob for damn the torpedoes, full speed ahead mode seems 
reasonable.

I wonder how it is that people have reported that Windows machines 
manage to do this?  Come to think of it, can windows even bond in 
software?  Maybe it's only possible on Windows with dual port cards 
where the drivers and hardware can make sure that the bonded interfaces 
service a single queue and maintain ordering that way?


