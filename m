From: Kalle Valo <kalle.valo@iki.fi>
Subject: Re: Network QoS support in applications
Date: Wed, 27 Jan 2010 08:59:43 +0200
Message-ID: <878wbkm3s0.fsf@purkki.valot.fi>
References: <87k4v5nuej.fsf@purkki.valot.fi>
	<20100126.041610.226004766.davem@davemloft.net>
	<87wrz5m3cd.fsf@purkki.valot.fi>
	<201001261407.04947.henning.rogge@fkie.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Henning Rogge <henning.rogge@fkie.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:33028 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102Ab0A0G7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 01:59:49 -0500
In-Reply-To: <201001261407.04947.henning.rogge@fkie.fraunhofer.de> (Henning Rogge's message of "Tue\, 26 Jan 2010 14\:06\:59 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Henning Rogge <henning.rogge@fkie.fraunhofer.de> writes:

> On Tue January 26 2010 13:56:50 Kalle Valo wrote:
>> So the idea is that the three left most bits (Class Selector
>> Codepoints from DiffServ RFC 2474) would contain these values from
>> IEEE 802.1d-2004 Annex G:
>> 
>> 0 best effort
>> 1 background
>> 2 (spare)
>> 3 excellent effort
>> 4 controlled load
>> 5 video
>> 6 voice
>> 7 network control
>> 
>> What do people think of this?
>
> The IETF is discussing about a traffic priority below "best effort"
> for bulk traffic at the moment. Something you use to fill up links
> if your can but drop it if you are not sure. So it might be a good
> idea to make "best efford" not zero.

I think 802.1d used zero for best effort to get it as the default. If
no class is set, the field will be zero and best effort is used.

-- 
Kalle Valo
