From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [RFC] tcp: setsockopt congestion control autoload
Date: Fri, 27 Oct 2006 00:44:07 +0200
Message-ID: <20061026224407.GA2018@c3po.0xdef.net>
References: <20061025110843.0cbd18a7@freekitty> <4540F076.70801@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Stephen Hemminger <shemminger@osdl.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c3po.0xdef.net ([217.172.181.57]:3595 "EHLO c3po.0xdef.net")
	by vger.kernel.org with ESMTP id S1161453AbWJZWoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 18:44:08 -0400
To: John Heffner <jheffner@psc.edu>
Content-Disposition: inline
In-Reply-To: <4540F076.70801@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* John Heffner | 2006-10-26 13:29:26 [-0400]:

>My reservation in doing this would be that as an administrator, I may 
>want to choose exactly what congestion control is available any any 
>given time.  The different congestion control algorithms are not 
>necessarily fair to each other.

ACK, completely right. A user without CAP_NET_ADMIN MUST NOT changed the
algorithm.  We know that there are some unfairness out there. And maybe some
time ago someone introduce a satellite-algorithm which is per definition
completely unfair to vanilla tcp.
We should guard this with a CAP_NET_ADMIN capability so that built-in modules
also shouldn't be enabled.

HGN

--
Signed and/or encrypted mails preferd. Key-Id = 0x98350C22
Fingerprint = 490F 557B 6C48 6D7E 5706  2EA2 4A22 8D45 9835 0C22 
