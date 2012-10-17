From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bug 1063038] Re: Broadcom BCM57780 Cannot Connect at
 Gigabit Speed using tg3 module.
Date: Tue, 16 Oct 2012 19:17:19 -0700
Message-ID: <1350440239.8764.34.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <50756903.1030709@justinzane.com>
 <50774C61.9050207@justinzane.com>
 <0E685F8B314BFB42AE2422915B7BDCC30FDCEF86@IRVEXCHMB07.corp.ad.broadcom.com>
 <DAAFBCC105999F468732FA900576CB450FFA61A5@IRVEXCHMB08.corp.ad.broadcom.com>
 <5077BAAA.3070208@justinzane.com>
 <DAAFBCC105999F468732FA900576CB450FFAB4AF@IRVEXCHMB08.corp.ad.broadcom.com>
 <5078B151.9000607@justinzane.com> <5078B1EF.6090401@broadcom.com>
 <5078E7B8.20903@justinzane.com>
 <DAAFBCC105999F468732FA900576CB450FFBB033@IRVEXCHMB08.corp.ad.broadcom.com>
 <507CD7E6.7070102@justinzane.com> <507D66A3.1050703@broadcom.com>
 <507DE8EF.4090807@justinzane.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "Nithin Sujir" <nsujir@broadcom.com>,
	"1063038@bugs.launchpad.net" <1063038@bugs.launchpad.net>,
	netdev@vger.kernel.org
To: "Justin Chudgar" <justin@justinzane.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4710 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755930Ab2JQCR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2012 22:17:57 -0400
In-Reply-To: <507DE8EF.4090807@justinzane.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-16 at 16:08 -0700, Justin Chudgar wrote: 
> With that said, though, I wish to express my displeasure with this
> practice artificially limiting the performance and/or capabilities of
> hardware via hidden firmware settings. It seems to be thoroughly
> contrary to both the liberty intended by Free Software and to the
> liberty to use purchased goods in any legal manner.
> 
> The end result that since Acer decided to deceptively limit hardware
> function via firmware, presumably to generate artificial pricepoint
> differentiation, Broadcom (not you guys) will agree not to fully support
> their hardware reflects poorly on Broadcom as well as Acer. I know that
> this will make me hesitant to buy devices from Acer or those
> incorporating Broadcom hardware. 

Firmware plays no role here.  It is their hardware design on the board
or on the RJ45 connector that makes 1Gbps not possible.  I wasn't aware
of this until now because Acer did not even require Linux support on
these systems.  So the right thing to do for these systems is to
recognize them as 10/100Mbps capable devices in the tg3 driver.
