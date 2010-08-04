From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: can TCP socket send buffer be over used?
Date: Wed, 4 Aug 2010 09:33:06 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1008040932030.19930@uplift.swm.pp.se>
References: <AANLkTi=Ma2yMVbgRnUUB6T1j=rHLb60oAXqCSbM35KgT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Jack Zhang <jack.zhang2011@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:49216 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758263Ab0HDHdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 03:33:09 -0400
In-Reply-To: <AANLkTi=Ma2yMVbgRnUUB6T1j=rHLb60oAXqCSbM35KgT@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Aug 2010, Jack Zhang wrote:

> For example, when I set the send buffer size to 128 KB, i could get a
> throughput up to 43 Mbps, which seems to be impossible as the (buffer
> size) / RTT is only 10 Mbps.

Are you sure the buffer actually corresponds to the congestion window TCP 
uses? I think you should use wireshark to dump the traffic and look in the 
TCP headers of the packets to see what is actually going on on the wire.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
