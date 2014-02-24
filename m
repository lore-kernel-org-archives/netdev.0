From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 4/5] be2net: wait longer to reap TX compls in
 be_close()
Date: Mon, 24 Feb 2014 09:31:15 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6C9608@AcuExch.aculab.com>
References: <57bc5399-f8f6-4c65-8cae-131c83d548ad@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Vasundhara Volam <vasundhara.volam@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>
To: 'Somnath Kotur' <somnath.kotur@emulex.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54042 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751622AbaBXJcN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 04:32:13 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27518-03 for <netdev@vger.kernel.org>;
 Mon, 24 Feb 2014 09:32:11 +0000 (GMT)
In-Reply-To: <57bc5399-f8f6-4c65-8cae-131c83d548ad@CMEXHTCAS1.ad.emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Somnath Kotur
> be_close() currently waits for a max of 200ms to receive all pending
> TX compls. This timeout value was roughly calcuated based on 10G
> transmission speeds and the TX queue depth. This timeout may not be
> enough when the link is operating at lower speeds or in
> multi-channel/SR-IOV configs with TX-rate limiting setting.
> Increase the timeout to 2000ms and also bail-out if there is
> a HW-error.

What about monitoring whether transmits are actually completing,
and giving up if none are completed within a suitable time period?

	David
