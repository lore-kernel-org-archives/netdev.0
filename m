From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 17/24] net: cdc_ncm: use netif_* and dev_* instead of pr_*
Date: Mon, 04 Nov 2013 09:59:17 +0100
Message-ID: <8738ncwniy.fsf@nemi.mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
	<1383301021-16613-18-git-send-email-bjorn@mork.no>
	<1383302214.13084.6.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48385 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752315Ab3KDI7j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 03:59:39 -0500
In-Reply-To: <1383302214.13084.6.camel@joe-AO722> (Joe Perches's message of
	"Fri, 01 Nov 2013 03:36:54 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> writes:

> You did most all the multi-line statement
> alignment perfectly but missed a couple.

Damn! OK, that will teach me to do "checkpatch --strict" before
submitting.

> Maybe in a follow-on patch.

Yes, I'll fix this when I get around to the next series for this driver=
=2E

Thanks.


Bj=C3=B8rn

>> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> []
>> @@ -1031,17 +1035,13 @@ cdc_ncm_speed_change(struct usbnet *dev,
>>  	 * device speed. Do print it instead.
>>  	 */
>>  	if ((tx_speed > 1000000) && (rx_speed > 1000000)) {
>> -		printk(KERN_INFO KBUILD_MODNAME
>> -		       ": %s: %u mbit/s downlink "
>> -		       "%u mbit/s uplink\n",
>> -		       dev->net->name,
>> +		netif_info(dev, link, dev->net,
>> +		       "%u mbit/s downlink %u mbit/s uplink\n",
>>  		       (unsigned int)(rx_speed / 1000000U),
>>  		       (unsigned int)(tx_speed / 1000000U));
>>  	} else {
>> -		printk(KERN_INFO KBUILD_MODNAME
>> -		       ": %s: %u kbit/s downlink "
>> -		       "%u kbit/s uplink\n",
>> -		       dev->net->name,
>> +		netif_info(dev, link, dev->net,
>> +		       "%u kbit/s downlink %u kbit/s uplink\n",
>>  		       (unsigned int)(rx_speed / 1000U),
>>  		       (unsigned int)(tx_speed / 1000U));
>>  	}
