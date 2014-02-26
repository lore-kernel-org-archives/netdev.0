From: David Miller <davem@davemloft.net>
Subject: Re: RTL8153 fails to get link after applying c7de7dec2 to 3.8
 kernel
Date: Wed, 26 Feb 2014 11:58:31 -0500 (EST)
Message-ID: <20140226.115831.255949929805078536.davem@davemloft.net>
References: <D7709D6F234143CDB4D0B6B27C53D3F4@realtek.com.tw>
	<CANEJEGuCWZSBNppE+W2_UW8mDZYQCBpsJTjfwuizjPMpY+wZzw@mail.gmail.com>
	<6055EBDEF51C4CDDBE25766ED5CACA67@realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@google.com, inky.yoo@samsung.com, netdev@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbaBZQ6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 11:58:35 -0500
In-Reply-To: <6055EBDEF51C4CDDBE25766ED5CACA67@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: hayeswang <hayeswang@realtek.com>
Date: Wed, 26 Feb 2014 18:13:00 +0800

> Grant Grundler [mailto:grundler@google.com] 
>> Sent: Tuesday, February 25, 2014 12:18 AM
>> To: hayeswang
>> Cc: Inki Yoo; netdev
>> Subject: Re: RTL8153 fails to get link after applying 
>> c7de7dec2 to 3.8 kernel
> [...]
>> Does Realtek have a publicly available tool that I can use to set all
>> customization back to "official" values?
> 
> Please contact with the person who give you the dangle.
> You should need the another one.

This is not an appropriate response.

Your company made a chip, and people are going to repackage it and
reuse it in their own implementations.

Sometimes they will set jumpers incorrectly, add bugs to the firmware,
and make other mistakes.

When you are made explicitly awre of such situations, your driver
should absolutely strive to handle that, rather than refuse to.

It is mysterious to me when a driver author behaves in such a way that
they seem to want their driver to work on fewer instances of their
hardware rather than support more of them.
