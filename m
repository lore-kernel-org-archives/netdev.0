From: "David Laight" <David.Laight@ACULAB.COM>
Subject: xmm registers in amd64 drivers
Date: Thu, 19 Sep 2013 11:31:46 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B734B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "Network Development" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45389 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752136Ab3ISKdu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 06:33:50 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15141-03 for <netdev@vger.kernel.org>;
 Thu, 19 Sep 2013 11:33:47 +0100 (BST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I realise this isn't quite the right list for this question.
But I suspect someone will know the answer!

I've just compiled one of our drivers (an ss7 protocol stack)
on a much newer system than the one we usually use
(ubunto 13.04 with gcc 4.7.3 rather than debian lenny).

I've bodged around some strict-aliasing and const-cast warnings
- the usage all look safe.

Looking at the object code I noticed that all the stdarg
functions now contain code to conditionally save the xmm
registers.

Is this now considered 'normal' or am I missing a compiler flag?

I know I've looked at the code before since I tried adding
enough fixed parameters to one of the functions to get all
the variable ones on-stack hoping that would optimise the
accesses - it didn't.

	David
