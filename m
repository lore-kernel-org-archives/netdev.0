From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 1/3] lan78xx: replace devid to chipid & chiprev
Date: Wed, 10 Feb 2016 22:49:10 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404ABB1E@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D404AB9F2@CHN-SV-EXMX02.mchp-main.com>
 <56BBAD6C.6070901@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: <sergei.shtylyov@cogentembedded.com>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:26837 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750864AbcBJWtM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 17:49:12 -0500
In-Reply-To: <56BBAD6C.6070901@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Sergei & Andrew,
Will remove extra brackets and repost.

Woojung 

> > @@ -471,7 +472,7 @@ static int lan78xx_read_raw_eeprom(struct
> lan78xx_net *dev, u32 offset,
> >   	 */
> >   	ret = lan78xx_read_reg(dev, HW_CFG, &val);
> >   	saved = val;
> > -	if ((dev->devid & ID_REV_CHIP_ID_MASK_) == 0x78000000) {
> > +	if ((dev->chipid) == ID_REV_CHIP_ID_7800_) {


> > @@ -505,7 +506,7 @@ static int lan78xx_read_raw_eeprom(struct
> lan78xx_net *dev, u32 offset,
> >
> >   	retval = 0;
> >   exit:
> > -	if ((dev->devid & ID_REV_CHIP_ID_MASK_) == 0x78000000)
> > +	if ((dev->chipid) == ID_REV_CHIP_ID_7800_)


> > @@ -539,7 +540,7 @@ static int lan78xx_write_raw_eeprom(struct
> lan78xx_net *dev, u32 offset,
> >   	 */
> >   	ret = lan78xx_read_reg(dev, HW_CFG, &val);
> >   	saved = val;
> > -	if ((dev->devid & ID_REV_CHIP_ID_MASK_) == 0x78000000) {
> > +	if ((dev->chipid) == ID_REV_CHIP_ID_7800_) {


> > @@ -587,7 +588,7 @@ static int lan78xx_write_raw_eeprom(struct
> lan78xx_net *dev, u32 offset,
> >
> >   	retval = 0;
> >   exit:
> > -	if ((dev->devid & ID_REV_CHIP_ID_MASK_) == 0x78000000)
> > +	if ((dev->chipid) == ID_REV_CHIP_ID_7800_)
