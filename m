From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] tcp: ECN blackhole should not force quickack mode
Date: Mon, 26 Sep 2011 08:00:43 -0400
Message-ID: <1317038443.1865.40.camel@mojatatu>
References: <1316757739.2560.12.camel@edumazet-laptop>
	 <1316825745.1865.24.camel@mojatatu>
	 <1316978684.2531.7.camel@edumazet-laptop>
	 <1316999266.1865.35.camel@mojatatu>  <1316999597.1865.37.camel@mojatatu>
	 <1317025614.2557.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
Received: from mail-yw0-f46.google.com ([209.85.213.46]:37579 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314Ab1IZMAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 08:00:50 -0400
Received: by ywb5 with SMTP id 5so4196324ywb.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 05:00:50 -0700 (PDT)
In-Reply-To: <1317025614.2557.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-09-26 at 10:26 +0200, Eric Dumazet wrote:

> This refers to additions to RFC 2481 : This was refined by RFC 3168, and
> the retransmitted TCP packets requirement is part of the final RFC :

Ah, yes - thats where it went.

> 
> BTW, the ECN+ proposal (RFC 5562 :  Adding Explicit Congestion
> Notification (ECN) Capability to TCP's SYN/ACK Packets) would allow the
> client (receiving SYNACK message with ECT flags) to set the TCP_ECN_SEEN
> I added in my patch, allowing even the first (retransmitted) data packet
> to trigger quickack mode.

Excellent ;->
Are you going to add 5562 support?

cheers,
jamal
