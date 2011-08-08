From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: 802.3ad bonding brain damaged?
Date: Mon, 08 Aug 2011 14:14:35 -0600
Message-ID: <4E4043AB.1060500@genband.com>
References: <4E3EECF6.90409@cfl.rr.com> <1312790234.7020.26.camel@arkology.n2.diac24.net> <4E4041B5.5040908@cfl.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Phillip Susi <psusi@cfl.rr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og126.obsmtp.com ([64.18.2.206]:39880 "EHLO
	exprod7og126.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab1HHUPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 16:15:42 -0400
In-Reply-To: <4E4041B5.5040908@cfl.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2011 02:06 PM, Phillip Susi wrote:
> On 8/8/2011 3:57 AM, David Lamparter wrote:
>> No, it isn't. 802.3ad/.1AX explicitly requires that no packet
>> re-ordering may ever occur, which can only be guaranteed by enqueueing
>> packets for one host on one TX interface. This behaviour is mandated by
>> 802.1AX-2008 page 15 which reads:
>
> Outch, that does cause a big problem for store-and-forward switching.
> You basically can't split up packets from a single stream without very
> careful cut-through switching, which we obviously can't do in Linux.
> That seems a rather silly requirement given that higher level protocols
> already deal with packet reordering. Why not an option to say stuff the
> standard?

Bonding doesn't know about "higher level protocols".  Also, assuming 
that higher level protocols already deal with reordering can be 
dangerous.  I've dealt with network protocols and apps that assumed 
there would be no reordering because at the time they were written they 
used point-to-point links.  They actually work fairly well with single 
links, so it would be reasonable to try and keep them working with 
bonded links.

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
