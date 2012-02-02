From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: VLAN 1 - Native
Date: Thu, 02 Feb 2012 13:10:16 +0100
Message-ID: <m34nv977x3.fsf@ursa.amorsen.dk>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
	<1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
	<1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>
	<CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>
	<1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yao zhao <yao.development@gmail.com>,
	Leonardo Uzcudun <uzcudunl@yahoo.it>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.ipvision.dk ([217.195.186.4]:40198 "EHLO
	gate2.ipvision.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755828Ab2BBMKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 07:10:20 -0500
In-Reply-To: <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	(Eric Dumazet's message of "Wed, 01 Feb 2012 16:05:23 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> There is no ID reserved to untagged traffic in the 802.1Q specs, since
> by definition, if traffic is untagged, there is _no_ VLAN tag in the
> frame.

This is not entirely true. If you want to send 802.1p-tagged packets
without a specific VLAN, you should use the 0 tag. I would say that
comes quite close to "The ID reserved to untagged traffic is 0".

It is, however, not 1.


/Benny
