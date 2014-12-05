From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery
 stalls on v3.12+
Date: Fri, 05 Dec 2014 05:26:25 -0800
Message-ID: <1417785985.4322.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
	 <2335530.7OPnEQXbmV@h2o.as.studentenwerk.mhn.de>
	 <1769392.YOU9Lj6NQS@h2o.as.studentenwerk.mhn.de>
	 <1841985.3SsQX9ZHP0@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Thomas Jarosch <thomas.jarosch@intra2net.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:39619 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbaLEN01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 08:26:27 -0500
Received: by mail-ig0-f169.google.com with SMTP id hl2so759627igb.0
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 05:26:27 -0800 (PST)
In-Reply-To: <1841985.3SsQX9ZHP0@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-12-05 at 13:09 +0100, Wolfgang Walter wrote:
> Hello,
> 
> as reverting this patch fixes this rather annoying problem: is it dangerous to 
> revert it as a workaround until the root cause is found?
> 

Unfortunately no, this patch fixes a serious issue.

We need to find the root cause of your problem instead of trying to work
around it.
