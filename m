From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] tcp: ECN blackhole should not force quickack mode
Date: Sun, 25 Sep 2011 21:07:46 -0400
Message-ID: <1316999266.1865.35.camel@mojatatu>
References: <1316757739.2560.12.camel@edumazet-laptop>
	 <1316825745.1865.24.camel@mojatatu>
	 <1316978684.2531.7.camel@edumazet-laptop>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Jim Gettys <jg@freedesktop.org>,
	Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:62520 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326Ab1IZBHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2011 21:07:53 -0400
Received: by ywb5 with SMTP id 5so3909242ywb.19
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2011 18:07:52 -0700 (PDT)
In-Reply-To: <1316978684.2531.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-09-25 at 21:24 +0200, Eric Dumazet wrote:

> 
> So we have somewhere a box that mask the TOS bits. This is a well known
> effect on some networks, unfortunately.

ok

> The 'linux funny extension' is wrong in this case, since I have no
> retransmits, no losses, yet my laptop is in quickack mode (it sends an
> ACK for every incoming data packet), because you assumed receiving a
> packet with no ECT bits means this packet was a retransmit.

No objection from me - only one corner case i can think of is if
expected behavior happens and the first data packet was a retransmit
(i.e you wouldnt have seen an ECT which you need for your heuristic),
but that is probably not a big a deal. 

In regards to the 'linux funny extension' - this was a brilliant idea
in my opinion back then from Alexey; lots of discussions happened but
I cant remember if it made it in some RFC or not (I will try to search
some old archives).

cheers,
jamal
