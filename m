From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: tg3: regression of netdev stats
Date: Sat, 2 Mar 2013 10:56:06 -0800
Message-ID: <51324B46.1050700@broadcom.com>
References: <878v67xnkr.fsf@devron.myhome.or.jp>
 <1362152836.6212.27.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <87y5e6wcv1.fsf@devron.myhome.or.jp>
 <87txouwcf8.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "OGAWA Hirofumi" <hirofumi@mail.parknet.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1209 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752369Ab3CBS4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Mar 2013 13:56:19 -0500
In-Reply-To: <87txouwcf8.fsf@devron.myhome.or.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 3/1/2013 10:20 PM, OGAWA Hirofumi wrote:
> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> writes:
>
>> zero). But, e.g. ping/nfs itself works fine.
>>
>> BTW, chip is
>>
>> 02:00.0 Ethernet controller [0200]: Broadcom Corporation NetLink BCM57788 Gigabit Ethernet PCIe [14e4:1691] (rev 01)
>>
>> tg3 0000:02:00.0 eth0: Tigon3 [partno(BCM57788) rev 57780001] (PCI Express) MAC address d4:be:d9:a6:a3:3b
>> tg3 0000:02:00.0 eth0: attached PHY driver [Broadcom BCM57780] (mii_bus:phy_addr=200:01)
>
> With some read, this chip seems to be using PHYLIB, and PHYLIB modify
> carrier state, so ->link_up confuses with it?
>

Yes, this may be relevant. I'll investigate further with this device.


> Thanks.
>
