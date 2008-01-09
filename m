From: David Miller <davem@davemloft.net>
Subject: Re: SACK scoreboard
Date: Tue, 08 Jan 2008 23:58:33 -0800 (PST)
Message-ID: <20080108.235833.137421765.davem@davemloft.net>
References: <Pine.LNX.4.64.0712111547300.18529@kivilampi-30.cs.helsinki.fi>
	<20080107.233617.203640686.davem@davemloft.net>
	<Pine.LNX.4.64.0801081258050.12911@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lachlan.andrew@gmail.com, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58196
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752008AbYAIH6d convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 02:58:33 -0500
In-Reply-To: <Pine.LNX.4.64.0801081258050.12911@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 8 Jan 2008 14:12:47 +0200 (EET)

> If I'd hint my boss that I'm involved in something like this I'd
> bet that he also would get quite crazy... ;-) I'm partially paid
> for making TCP more RFCish :-), or at least that the places where
> thing diverge are known and controllable for research purposes.

RFCs are great guides by which to implement things, but they have been
often completely wrong or not practicle to follow strictly.

The handling of out of order ACKs with timestamps is my favorite
example.  Nobody performs an RFC compliant timestamp check on ACK
packets, or else their performance would go into the toilet during
packet reordering.

The URG bit setting is another one.

Especially when, practically speaking, we can in fact make changes
like I believe we can here I think we should.
