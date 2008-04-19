From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [patch 1/3] hci_usb: do not initialize static variables to 0
Date: Sat, 19 Apr 2008 18:12:45 +0200
Message-ID: <20080419161245.GA1577@elf.ucw.cz>
References: <200804182046.m3IKkp7P014625@imap1.linux-foundation.org> <A7F393C1-AEAC-4BC5-B7A4-A9CC78179CDF@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, hidave.darkstar@gmail.com,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.31.123]:37847 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbYDSQME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 12:12:04 -0400
Content-Disposition: inline
In-Reply-To: <A7F393C1-AEAC-4BC5-B7A4-A9CC78179CDF@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri 2008-04-18 23:04:57, Marcel Holtmann wrote:
> Hi Andrew,
>
>> hci_usb: do not initialize static variables to 0.
>>
>> Signed-off-by: Pavel Machek <pavel@suse.cz>
>> Cc: Marcel Holtmann <marcel@holtmann.org>
>> Cc: Dave Young <hidave.darkstar@gmail.com>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>
>> drivers/bluetooth/hci_usb.c |   14 +++++++-------
>> 1 file changed, 7 insertions(+), 7 deletions(-)
>>
>> diff -puN 
>> drivers/bluetooth/hci_usb.c~hci_usb-do-not-initialize-static-variables-to-0 
>> drivers/bluetooth/hci_usb.c
>> --- 
>> a/drivers/bluetooth/hci_usb.c~hci_usb-do-not-initialize-static-variables-to-0
>> +++ a/drivers/bluetooth/hci_usb.c
>> @@ -62,13 +62,13 @@
>> #define URB_ZERO_PACKET 0
>> #endif
>>
>> -static int ignore = 0;
>> -static int ignore_dga = 0;
>> -static int ignore_csr = 0;
>> -static int ignore_sniffer = 0;
>> -static int disable_scofix = 0;
>> -static int force_scofix = 0;
>> -static int reset = 0;
>> +static int ignore;
>> +static int ignore_dga;
>> +static int ignore_csr;
>> +static int ignore_sniffer;
>> +static int disable_scofix;
>> +static int force_scofix;
>> +static int reset;
>
> I know that some people don't like to do it and I agree, but in case of 
> module parameters, I prefer to have them clearly indicate what the default 
> value is. It is a lot easier to read for other people looking at the code. 
> So that one is a NAK from my side.

According to you noone should read this one, anyway :-)... and this
wastes space in vmlinux.
									Pavel	

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
