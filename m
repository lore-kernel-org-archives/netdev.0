From: Somnath Kotur <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net v2] be2net: Warn users of possible broken
 functionality on BE2 cards with very old FW versions with latest driver
Date: Thu, 17 Oct 2013 05:41:13 +0000
Message-ID: <7F44EA5110810A40B7DAFB605C41975D2C89ECBD@CMEXMB1.ad.emulex.com>
References: <cca19523-3f51-4f87-b0e1-2ecec6ba37d4@CMEXHTCAS1.ad.emulex.com>
 <20131007.123116.1462434377931881914.davem@davemloft.net>
 <525EA9E7.409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:21899 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822Ab3JQFlO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 01:41:14 -0400
In-Reply-To: <525EA9E7.409@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Ivan Vecera [mailto:ivecera@redhat.com]
> Sent: Wednesday, October 16, 2013 8:30 PM
> To: Somnath Kotur
> Cc: David Miller; netdev@vger.kernel.org
> Subject: Re: [PATCH net v2] be2net: Warn users of possible broken
> functionality on BE2 cards with very old FW versions with latest driver
> 
> On 10/07/2013 06:31 PM, David Miller wrote:
> > From: Somnath Kotur <somnath.kotur@emulex.com>
> > Date: Thu, 3 Oct 2013 15:34:29 +0530
> >
> >> +	if (BE2_chip(adapter) && memcmp(adapter->fw_ver, "4.", 2) < 0) {
> >> +		dev_err(dev, "Firmware version is too old.IRQs may not
> work\n");
> >
> > So many grammatical mistakes in one line.
> >
> > First sentence got a period, second one did not.
> >
> > Missing space between period and second sentence.
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org More majordomo
> info
> > at  http://vger.kernel.org/majordomo-info.html
> >
> Som, any plan to send v3?
> 
> Ivan
HI Ivan,
   Yes , the problem was I was trying to stick within the 80 chars line limit , the missing space above would have pushed it over
needlessly warranting an extra line to accommodate a character.
Will rework the sentence using Joe Perches's suggestions as well as address Ben Hutching's concerns.
Stay tuned.

Thanks
Som
