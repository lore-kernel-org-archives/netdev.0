From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Subject: Re: [PATCH/RFC] [v3] TCP: use non-delayed ACK for congestion	control
 RTT
Date: Sun, 30 Dec 2007 12:35:04 +0000
Message-ID: <20071230123504.GB23931@nuim.ie>
References: <Pine.LNX.4.64.0712191241450.11908@kivilampi-30.cs.helsinki.fi>
 <20071219113125.GF31508@nuim.ie>
 <Pine.LNX.4.64.0712191511120.14629@kivilampi-30.cs.helsinki.fi>
 <20071221.031400.194877955.davem@davemloft.net>
 <20071221133106.GA7995@nuim.ie>
 <Pine.LNX.4.64.0712211545580.7301@kivilampi-30.cs.helsinki.fi>
 <20071230011500.GA30997@nuim.ie>
 <Pine.LNX.4.64.0712301139150.31698@kivilampi-30.cs.helsinki.fi>
Reply-To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:57603 "EHLO mango.nuim.ie"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751891AbXL3MfA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2007 07:35:00 -0500
Content-disposition: inline
Received: from boing.hamilton.local ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTP id <0JTV006IN4A8CF20@mango.nuim.ie> for
 netdev@vger.kernel.org; Sun, 30 Dec 2007 12:34:56 +0000 (GMT)
In-reply-to: <Pine.LNX.4.64.0712301139150.31698@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 30 Dec 2007, Ilpo J=E4rvinen wrote:

> I guess the non-minimum TSO delays are only significant in case there=
 was=20
> something unexpectional happening and in such case we definately want=
 to=20
> have some measurements taken.

Broadly speaking, delay-based schemes need as much information about th=
e
queueing delay as possible so more points are generally useful,
particularly if the delay is fluctuating rapidly.

When we started looking at delay-based schemes we had trouble with dela=
y
information fluctuating wildly due to TSO.  John Heffner made a change
(that I can't find at the minute) which reduced a TSO timeout and seeme=
d to
reduce this problem greatly.  It's worth bearing in mind though that TS=
O
may cause spuriously high delay measurements. =20

Gavin

