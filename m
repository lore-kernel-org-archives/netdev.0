From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 02/12] tipc: Add "max_ports" configuration parameter
Date: Fri, 31 May 2013 10:25:34 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B725E@saturn3.aculab.com>
References: <20130531082538.GB17727@eerihug-hybrid.ki.sw.ericsson.se> <20130531.012922.204204156468438634.davem@davemloft.net> <20130531083455.GA7568@eerihug-hybrid.ki.sw.ericsson.se> <20130531.014028.420559536226155172.davem@davemloft.net> <20130531092302.GA8131@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <paul.gortmaker@windriver.com>, <netdev@vger.kernel.org>,
	<jon.maloy@ericsson.com>, <ying.xue@windriver.com>
To: "Erik Hugne" <erik.hugne@ericsson.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34011 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754364Ab3EaJ2J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 05:28:09 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02898-08 for <netdev@vger.kernel.org>;
 Fri, 31 May 2013 10:28:03 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130531092302.GA8131@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > We never shrink the hash tables once we've grown them.  That's a
> > reasonable way to behave.
> 
> Very well.
> Currently, the refs/portID's are built up of a random part, and an index
> part. The index is obtained by masking against the table size.
> If the table is allowed to grow, we must remove the random part from the
> portID. Otherwise we would index out a nonexistant or wrong port
> from a received packet..

No - you just copy the entry into the correct location in the
new array.
One of the 'random' bits becomes an 'index' bit.

	David
