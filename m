From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery
 stalls on v3.
Date: Fri, 12 Dec 2014 14:31:49 -0800
Message-ID: <1418423509.13491.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
	 <2630078.LdJXSsPB40@h2o.as.studentenwerk.mhn.de>
	 <1418405225.13491.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <4013455.miJUA6iczs@h2o.as.studentenwerk.mhn.de>
	 <548B5E6E.6010208@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Walter <linux@stwm.de>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:32856 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbaLLWbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 17:31:52 -0500
Received: by mail-ig0-f173.google.com with SMTP id r2so2262640igi.0
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2014 14:31:51 -0800 (PST)
In-Reply-To: <548B5E6E.6010208@intra2net.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-12-12 at 22:30 +0100, Thomas Jarosch wrote:

> if it's any help: Disabling TX checksumming prevents the hang
> even on an unpatched 3.14.x kernel. You could check with your debug statements
> in place the path of the packets with and without TX checksumming.

Disabling TX checksum automatically disables GSO.

Disabling TSO/GSO is the real 'cure' for the time being, you can keep TX
checksums.
