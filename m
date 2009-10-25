From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Sun, 25 Oct 2009 23:41:54 +0100
Message-ID: <20091025224153.GB20987@nuttenaction>
References: <200910252158.53921.opurdila@ixiacom.com>
 <4AE4C1FA.7000002@gmail.com>
 <200910252355.32640.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:48107 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754294AbZJYWlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 18:41:50 -0400
Content-Disposition: inline
In-Reply-To: <200910252355.32640.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Octavian Purdila | 2009-10-25 23:55:32 [+0200]:

>My results shows that new17 is better or very close to jhash2. And I think its 
>lighter then jhash too.

If new17 is very close to jhash/jhash2 then the cycles comes into play.
Anyway, there is already a very potent hash interface in form of jhash{,2}.

+1 for jhash2

HGN

PS: great work! ;)

PPS: http://libhashish.sourceforge.net/ have some real hash benchmarks in form
of avalanche test and some others too. It does not really matter here because
Jenkins performs _nearly_ perfect in all cases. ;)

-- 
Hagen Paul Pfeifer <hagen@jauu.net>  ||  http://jauu.net/
Telephone: +49 174 5455209           ||  Key Id: 0x98350C22
Key Fingerprint: 490F 557B 6C48 6D7E 5706 2EA2 4A22 8D45 9835 0C22
