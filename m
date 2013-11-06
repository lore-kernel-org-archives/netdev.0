From: "David Laight" <David.Laight@ACULAB.COM>
Subject: Generating fragmented skb
Date: Wed, 6 Nov 2013 12:31:16 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73E6@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51542 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756350Ab3KFMff convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 07:35:35 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17138-03 for <netdev@vger.kernel.org>;
 Wed,  6 Nov 2013 12:35:34 +0000 (GMT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What is the easiest way to generate fragmented skb?
I'm trying to test the xhci USB bulk code using a couple
of USB ethernet devices (smsc95xx and ax88179_178a).
I think the latter should support TCP segmentation offload.

FWIW some tests that seemed to imply the ax88179_178a needed
the ZLP avoidance code may have been caused because the
xhci driver completely ignored USB_ZETO_PACKET.

	David
