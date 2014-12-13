From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery
 stalls on v3.
Date: Fri, 12 Dec 2014 16:15:40 -0800
Message-ID: <1418429740.13491.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
	 <548B5E6E.6010208@intra2net.com>
	 <1418423509.13491.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1500356.bBOpW4o4zG@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:54060 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbaLMAPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 19:15:45 -0500
Received: by mail-ie0-f174.google.com with SMTP id rl12so7917732iec.19
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2014 16:15:45 -0800 (PST)
In-Reply-To: <1500356.bBOpW4o4zG@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-12-13 at 00:47 +0100, Wolfgang Walter wrote:

> I can't disable it as the driver will not allow it:
> # ethtool -K eth0 tx off
> Cannot change tx-checksumming
> Could not change any device features

Sounds a bug in itself :(
