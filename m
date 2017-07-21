From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] bluetooth: document config options
Date: Fri, 21 Jul 2017 12:55:59 +0200
Message-ID: <CC4E04D7-0328-427A-AB51-69641FE376E9@holtmann.org>
References: <20170721074957.GA12640@amd>
 <CDF602D5-78C6-4F97-9C12-3E6AD3AA6C37@holtmann.org>
 <20170721104228.GA9448@amd>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        linux-bluetooth@vger.kernel.org,
        kernel list <linux-kernel@vger.kernel.org>,
        Netdev list <netdev@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170721104228.GA9448@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel,

>>> Kernel config options should include useful help text; I had to look
>>> up the terms on wikipedia.
>>> 
>>> Signed-off-by: Pavel Machek <pavel@ucw.cz>
>>> 
>>> diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
>>> index 68f951b..133c8a6 100644
>>> --- a/net/bluetooth/Kconfig
>>> +++ b/net/bluetooth/Kconfig
>>> @@ -45,6 +45,8 @@ config BT_BREDR
>>> 	bool "Bluetooth Classic (BR/EDR) features"
>>> 	depends on BT
>>> 	default y
>>> +	help
>>> +	  Support Bluetooth version 1 and 2 connections.
>> 
>> so this is actually not correct. Version 5.0 is also Bluetooth BR/EDR.
>> 
>> I am fine if use the terms "Basic Rate" and "Enhanced Data Rate" in the description, but the version numbers are kinda not how this works. So some alternative wording needs to be used:
>> 
>> "Bluetooth Classic includes support for Basic Rate (BR) available with Bluetooth version 1.0b or later and support for Enhanced Data Rate (EDR) available with Bluetooth version 2.0 or later."
>> 
> 
> Ok, works for me.
> 
>>> +	help
>>> +	  Bluetooth 3 introduces high-speed mode where bluetooth endpoints
>>> +	  negotiate fast connection over WIFI. This controls its support.
>> 
>> Again, while Bluetooth version 3.0 introduces HS support, it is not what is selecting this.
>> 
>> I think here we can write something like this:
>> 
>> "Bluetooth High Speed includes support for off-loading Bluetooth connections via 802.11 physical layer available with Bluetooth version 3.0 or later."
>> 
> 
> Ok.
> 
>>> config BT_LE
>>> 	bool "Bluetooth Low Energy (LE) features"
>>> 	depends on BT
>>> 	default y
>>> +	help
>>> +	  Bluetooth 4 introduces special low-energy protocol, designed
>>> +	  for simple devices. This controls its support.
>> 
>> I think here it is also better to have an alternative text:
>> 
>> "Bluetooth Low Energy includes support low-energy physical layer available with Bluetooth version 4.0 or later."
>> 
> 
> Ok. Do I understand it correctly that Bluetooth LE basically has
> nothing to do with bluetooth, and that Bluetooth 2 hardware will not
> be able to detect / communicate with Bluetooth LE hardware?

if you have LE only on one side and BR/EDR only on the other side, then they can not communicate with each other. You need at least one side with dual-mode BR/EDR/LE support.

Regards

Marcel
