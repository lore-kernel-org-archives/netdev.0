From: Steven Blake <slblake@petri-meat.com>
Subject: Re: Network QoS support in applications
Date: Tue, 26 Jan 2010 10:29:20 -0500
Message-ID: <189614e81eab48b8189ee99236902df3@petri-meat.com>
References: <87k4v5nuej.fsf@purkki.valot.fi> <4B5ED254.7010104@trash.net> <877hr5nkx0.fsf@purkki.valot.fi> <20100126.041610.226004766.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: kalle.valo@iki.fi, kaber@trash.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elom.tchmachines.com ([208.76.80.198]:50018 "EHLO
	elom.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752022Ab0AZP33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 10:29:29 -0500
In-Reply-To: <20100126.041610.226004766.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jan 2010 04:16:10 -0800 (PST), David Miller
<davem@davemloft.net>
wrote:

> From: Kalle Valo <kalle.valo@iki.fi>
> Date: Tue, 26 Jan 2010 13:51:55 +0200
> 
>> Let's take a bittorrent client as an example. The traffic it generates
>> is not important and it doesn't matter if bittorrent packets have
>> lower priority compared to other streams. What SO_PRIORITY value
>> should all bittorrent clients to use to mark their packets as low
>> priority (for example background class from IEEE 802.1d Annex G).
> 
> This is a local policy decision.
> 
> There is no universal way of doing any of this, really.

You are correct.  However, RFC 4594 is an attempt to get applications and
network operators on the same page.  There is no harm done if apps set DSCP
values in accordance with this RFC.

Regarding Bittorrent priority, see LEDBAT
http://www.ietf.org/dyn/wg/charter/ledbat-charter.html.


Regards,

// Steve
