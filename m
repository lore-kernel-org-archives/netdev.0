From: Jeff Garzik <jeff@garzik.org>
Subject: [Fwd: Re: wan/pc300 bug found]
Date: Tue, 14 Nov 2006 09:42:07 -0500
Message-ID: <4559D5BF.3080605@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020402090302070305080504"
Cc: Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:15806 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965904AbWKNOmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 09:42:12 -0500
To: Krzysztof Halasa <khc@pm.waw.pl>,
	Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020402090302070305080504
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

FYI...  I'm certainly willing to remove pc300, if nobody wants it.

But I am unsure whether this is a case of "vendor doesn't care" or 
"users don't care", which are two very different things...

	Jeff



--------------020402090302070305080504
Content-Type: message/rfc822;
 name="Re: wan/pc300 bug found"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="Re: wan/pc300 bug found"

X-Account-Key: account2
Return-path: <Daniela.Squassoni@avocent.com>
Envelope-to: jeff@garzik.org
Delivery-date: Tue, 14 Nov 2006 11:54:49 +0000
Received: from srv1.dvmed.net ([207.234.209.181])
	by mail.dvmed.net with esmtps (Exim 4.62 #1 (Red Hat Linux))
	id 1GjwsL-0006pw-GS
	for jeff@garzik.org; Tue, 14 Nov 2006 11:54:49 +0000
Received: from mail2.avocent.com ([198.177.232.249] helo=mail.avocent.com)
	by srv1.dvmed.net with esmtp (Exim 4.62 #1 (Red Hat Linux))
	id 1GjwrB-00044G-Ch
	for jeff@garzik.org; Tue, 14 Nov 2006 11:53:53 +0000
X-MimeOLE: Produced By Microsoft Exchange V6.5
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Subject: RE: wan/pc300 bug found
Date: Tue, 14 Nov 2006 05:43:29 -0600
Message-ID: <1EF69AC43C5ABC49985E42B84575ADB7091CEA8E@hsv-email.corp.avocent.com>
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
Thread-Topic: wan/pc300 bug found
Thread-Index: AcblkTj6NhhyxYZlRcSWtJWgKaakzAiT9HkW
References: <20061001163559.GA8649@havoc.gtf.org>
From: "Squassoni, Daniela" <Daniela.Squassoni@avocent.com>
To: "Jeff Garzik" <jeff@garzik.org>
Cc: "Rosalino, Wanda" <Wanda.Rosalino@avocent.com>
X-Spam-Score: -2.6 (--)
X-Spam-Report: SpamAssassin version 3.1.7 on srv1.dvmed.net summary:
	Content analysis details:   (-2.6 points, 5.0 required)


Jeff,

As PC300 is not being produced anymore, we decided that the best =
solution is to remove its driver from the kernel. I will send you a =
patch to do so, as soon as possible.

Best regards,

Daniela


-----Original Message-----
From: Jeff Garzik [mailto:jeff@garzik.org]
Sent: Sun 10/1/2006 1:35 PM
To: pc300@cyclades.com; khc@pm.waw.pl; netdev@vger.kernel.org; LKML; =
Andrew Morton
Subject: wan/pc300 bug found
=20

The following gcc warning indicates a bug:

drivers/net/wan/pc300_drv.c: In function 'cpc_open':
drivers/net/wan/pc300_drv.c:2870: warning: 'br' may be used =
uninitialized in this function

clock_rate_calc() is not checked for a negative return value.




--------------020402090302070305080504--
