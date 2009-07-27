From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: tty_register_device NULL pointer dereference in 2.6.31-rc4
Date: Mon, 27 Jul 2009 13:39:03 +0200
Message-ID: <4A6D91D7.6030204@hartkopp.net>
References: <4A6AD807.6060706@hartkopp.net> <20090725115011.7ddf8d00@lxorguk.ukuu.org.uk> <1248520053.28545.156.camel@violet> <20090725131046.0f076f37@lxorguk.ukuu.org.uk> <20090727095904.GA5442@darkstar> <4A6D8BA3.3030601@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:38157 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbZG0LjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 07:39:06 -0400
In-Reply-To: <4A6D8BA3.3030601@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp wrote:
> Dave Young wrote:
>> On Sat, Jul 25, 2009 at 01:10:46PM +0100, Alan Cox wrote:
>>>>> tty_register_device appears to have been called with a NULL pointer. Not
>>>>> sure why however.
>>>> if that is the pointer for the struct device, then that used to be fine
>>>> in the past. Not all RFCOMM device have a parent when they are created.
>>> The tty layer doesn't care about the struct device really. Nothing there
>>> has changed. The NULL passed appears to be the driver argument.
>> Agree with you, because in rfcomm_init, rfcomm thread run before tty initilized, the following patch may fix the problem.
>> oliver, could you verify it it fix your problem?
> 
> Hi Dave,
> 
> i get this problem really seldom on my Laptop and i did not manage to get a
> reproducible Oops of that problem.
> 
> Anyway the code you are pointing to seems to have a problem and your added
> error handling looks good to me - even if i don't know if the initializations
> can be reordered in that way.
> 
> I'll try your patch, but it could take a *long* time to prove it right ;-)
> 

Just FYI:

Your patch compiled, the system booted without problems and nothing is broken
so far. I checked the BT, WLAN and BT dial-up with success. So it looks good
to me.

Regards,
Oliver
