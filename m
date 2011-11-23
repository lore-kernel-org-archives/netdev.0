From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 01/10] dql: Dynamic queue limits
Date: Wed, 23 Nov 2011 15:35:39 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEDD@saturn3.aculab.com>
References: <1322060288.17693.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Tom Herbert" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:41157 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756587Ab1KWPhd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 10:37:33 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 30671-02 for <netdev@vger.kernel.org>;
 Wed, 23 Nov 2011 15:37:31 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1322060288.17693.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> Another question is : Is DQL planned to work on 32bit arch ?
> 
> A fast interface can probably send more than 2^32 bytes for large
> slack_hold_time values, and wrap around.
> 
> If yes : We can use "unsigned int" instead of "unsigned long" to lower
> memory need on 64bit arch.
> 
> If no, "unsigned long" type is not enough on 32bit, or we 
> need to limit slack_hold_time to small intervals...

Another option would be divide the byte counts by (say) 16.
This would be good enough for the purpose, and increase the
time-to-wrap by a factor of 16.

	David
