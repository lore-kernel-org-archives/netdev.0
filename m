From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 11/15] drivers/net: delete old fujitsu based eth16i driver
Date: Tue, 22 Jan 2013 09:26:03 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B711B@saturn3.aculab.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com> <1358819182-28032-12-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Mika Kuoppala" <miku@iki.fi>
To: "Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49895 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751388Ab3AVJ2M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 04:28:12 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14897-02 for <netdev@vger.kernel.org>;
 Tue, 22 Jan 2013 09:28:08 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1358819182-28032-12-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If you had an etherteam 16i you really didn't want to be using it!
Of course, ICL used it as the standard ethernet card for
a few years!
Not that I kept any of them.

There was a hardware bug that meant that occaisionally
a receive packet would not be indicated to the host (not even
visible in the fifo) until the following packet arrived.

They would also reject received packets if the PHY signalled
a 'collision' even if the CRC was valid.
Most PHY only correctly detected collisions during transmit.
PHYs that correctly detect collision during RX were only
normally needed for MAC repeaters (which would also need
SQE disabled).

	David
