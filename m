From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH/RFC] ipv6: fib: Drop cached routes with dead neighbours on fib GC
Date: Fri, 11 Jan 2013 08:57:09 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7107@saturn3.aculab.com>
References: <1357753459-12872-1-git-send-email-roland@kernel.org> <20130110.141847.265135906896223944.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <roland@purestorage.com>
To: "David Miller" <davem@davemloft.net>, <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59892 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753213Ab3AKI7M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 03:59:12 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09066-07 for <netdev@vger.kernel.org>;
 Fri, 11 Jan 2013 08:59:02 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20130110.141847.265135906896223944.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Another reason we must make ipv6 like ipv4, which looks up neighbours
> on demand at packet output time rather than caching them in the route
> entries.

Presumable the neighbour could be left cached in the route entry
provided the code checks that the cached entry is still valid
and does a relookup if not (rather than a send-blackhole).

	David
