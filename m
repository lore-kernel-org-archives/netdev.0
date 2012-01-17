From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: /proc/net/tcp6 inconsistent line length
Date: Tue, 17 Jan 2012 13:33:01 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF49@saturn3.aculab.com>
References: <20120117152919.7746a3f9@wwwwww-701SD>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <abirvalg@lavabit.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56150 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753436Ab2AQNdF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 08:33:05 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01939-06 for <netdev@vger.kernel.org>;
 Tue, 17 Jan 2012 13:32:59 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20120117152919.7746a3f9@wwwwww-701SD>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> My application parses /proc/net/tcp6 at least 4 times per 
> second, so the overhead of figuring out the length of each 
> line and subtracting the offset is quite expensive.

I'd be surprised if you can detect the cost of calling
strchr(buf, '\n') on each line at the frequency.

It is probably far less than the other processing you
do on the line.

	David
