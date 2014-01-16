From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 11/13] net: mvneta: implement rx_copybreak
Date: Thu, 16 Jan 2014 09:14:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D45D866@AcuExch.aculab.com>
References: <1389856819-6503-1-git-send-email-w@1wt.eu>
 <1389856819-6503-12-git-send-email-w@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: 'Willy Tarreau' <w@1wt.eu>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47941 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751257AbaAPJQO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 04:16:14 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22295-08 for <netdev@vger.kernel.org>;
 Thu, 16 Jan 2014 09:16:08 +0000 (GMT)
In-Reply-To: <1389856819-6503-12-git-send-email-w@1wt.eu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Willy Tarreau
> calling dma_map_single()/dma_unmap_single() is quite expensive compared
> to copying a small packet. So let's copy short frames and keep the buffers
> mapped. We set the limit to 256 bytes which seems to give good results both
> on the XP-GP board and on the AX3/4.

Have you tried something similar for transmits?
Copying short tx into a preallocated memory area that is dma_mapped
at driver initialisation?

	David
