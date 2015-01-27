From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: make allyesconfig i386 build failure with next-20150122 (caused
 by fb_agm1264k-fl driver)
Date: Mon, 26 Jan 2015 18:42:48 -0800
Message-ID: <54C6FB28.3000304@roeck-us.net>
References: <CA+r1ZhhXF+hicy7JKo3jAbgSbO4KOLm6BwPosTKNb+E_Cb4yPQ@mail.gmail.com> <20150126215959.GA9853@roeck-us.net> <20150126224654.GA17166@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	devel <devel@driverdev.osuosl.org>, isdn@linux-pingi.de,
	netdev <netdev@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:47661 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbbA0Cmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 21:42:54 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YFw7C-002zP1-R8
	for netdev@vger.kernel.org; Tue, 27 Jan 2015 02:42:54 +0000
In-Reply-To: <20150126224654.GA17166@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/26/2015 02:46 PM, Greg Kroah-Hartman wrote:
> On Mon, Jan 26, 2015 at 01:59:59PM -0800, Guenter Roeck wrote:
>> On Thu, Jan 22, 2015 at 12:10:33PM -0700, Jim Davis wrote:
>>> make ARCH=i386 allyesconfig fails with
>>>
>>> drivers/staging/built-in.o: In function `reset':
>>> (.text+0x2ae89d): multiple definition of `reset'
>>> drivers/isdn/built-in.o:(.text+0x185dc2): first defined here
>>> make[1]: *** [drivers/built-in.o] Error 1
>>
>> Culprit:
>>
>> commit b2ebd4be6fa1d2329b63531b044f9e25474981cb
>> Author: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
>> Date:   Wed Dec 31 10:11:10 2014 +0100
>>
>>      staging: fbtft: add fb_agm1264k-fl driver
>>
>> A global function named 'reset' isn't really a good idea.
>>
>> Not that the global function with the same name in the isdn code
>> is better ;-).
>
> Agreed, the fbtft code is now fixed.  Patches to fix the isdn code would
> be gladly accepted as well :)
>

Did you have a look into the isdn code ? It will need someone
with a lot of spare time to clean this code up.

Guenter
