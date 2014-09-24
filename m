From: Heiko Schocher <hs@denx.de>
Subject: Re: [PATCH] usb: gadget: f_rndis: fix usb_interface_descriptor for
 rndis
Date: Wed, 24 Sep 2014 15:12:31 +0200
Message-ID: <5422C33F.400@denx.de>
References: <1411541339-32400-1-git-send-email-hs@denx.de> <5422B83A.8030406@gmail.com>
Reply-To: hs@denx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, Felipe Balbi <balbi@ti.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org,
	Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
	Michal Nazarewicz <mina86@mina86.com>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Macpaul Lin <macpaul@gmail.com>
To: Lars Melin <larsm17@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5422B83A.8030406@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Lars,

Am 24.09.2014 14:25, schrieb Lars Melin:
> On 2014-09-24 13:48, Heiko Schocher wrote:
>> use the values for RNDIS over Ethernet as defined in
>> http://www.usb.org/developers/defined_class
>> (search for RDNIS):
>>
>> - baseclass: 0xef (miscellaneous)
>> - subclass: 0x04
>> - protocol: 0x01
>>
> That is usb class, it is not the same thing as communication device class.
>> --- a/include/uapi/linux/usb/cdc.h
>> +++ b/include/uapi/linux/usb/cdc.h
>> @@ -12,6 +12,7 @@
>> #include <linux/types.h>
>> #define USB_CDC_SUBCLASS_ACM 0x02
>> +#define USB_CDC_SUBCLASS_RNDIS 0x04
> No, no, no.
> There is no CDC_SUBCLASS_RNDIS and you can not define one over an already used cdc subclass number, 0x04 is Multi-Channel Control Model

Ah, ok, so I have to define this values in a new header file, as there
is no current file for the USB_CLASS_MISC defines? Or is there a proper
place for them?

BTW: where do I find the "cdc subclass number, 0x04 is Multi-Channel
Control Model" define?

bye,
Heiko
-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
