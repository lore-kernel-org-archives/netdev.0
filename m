From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] ipv4: introduce ip_dst_mtu_secure and protect forwarding path against pmtu spoofing
Date: Fri, 20 Dec 2013 10:21:10 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B74BF@saturn3.aculab.com>
References: <20131219000759.GF3505@order.stressinduktion.org><20131219.001203.1942468169345523058.davem@davemloft.net><20131219121757.GD14429@order.stressinduktion.org> <20131219.143012.205185984019527730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <johnwheffner@gmail.com>, <netdev@vger.kernel.org>,
	<eric.dumazet@gmail.com>
To: "David Miller" <davem@davemloft.net>, <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44583 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756156Ab3LTKWq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 05:22:46 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03581-01 for <netdev@vger.kernel.org>;
 Fri, 20 Dec 2013 10:22:44 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131219.143012.205185984019527730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> No end host should have rp_filter on.  It unnecessarily makes our
> routing lookups much more expensive for zero gain on an end host.  But
> people convinced the distributions that turning it on everywhere by
> default was a good idea and it stuck.

Yes I spent a long time trying to get asymmetric routing within a
subnet working [1]. I didn't expect anything on the ingress side
would discard the packets - especially with the 'host based' IP
address scheme that linux uses.

	David

[1] I wanted a netperf RR test to send on one interface and
receive on another so that I could see whether the additional
delays were on the tx or rx side.
