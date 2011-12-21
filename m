From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/1] tcp: Replace constants with #define macros
Date: Wed, 21 Dec 2011 09:57:41 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF1E@saturn3.aculab.com>
References: <20111220.151809.1704705119739851376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<ilpo.jarvinen@helsinki.fi>, <hkchu@google.com>
To: "David Miller" <davem@davemloft.net>, <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35382 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752636Ab1LUJ7L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 04:59:11 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00644-04 for <netdev@vger.kernel.org>;
 Wed, 21 Dec 2011 09:59:09 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20111220.151809.1704705119739851376.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> > I assume you are talking about collision with userspace.  These
> > definitions are already protected by #ifdef  __KERNEL__.
> > That should be enough to protect against collisions with 
> userspace I think.
> 
> Within the kernel he means, please put a TCP_* prefix onto these
> values.

Given the values are currently:

> > +#define SACK_SEEN     (1 << 0)   /*1 = peer is SACK capable, */
> > +#define FACK_ENABLED  (1 << 1)   /*1 = FACK is enabled locally*/
> > +#define DSACK_SEEN    (1 << 2)   /*1 = DSACK was received from
peer*/

But the structure field member is 'sack_ok', unless it generates
very silly long lines - which in this case it probably doesn't -
it might even be worth prefixing with TCP_SACK_OK_ although
that might be deemed excessive!

	David
