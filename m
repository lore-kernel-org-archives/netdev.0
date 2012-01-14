From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Sat, 14 Jan 2012 18:36:56 +0100
Message-ID: <4F11BD38.7060109@broadcom.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com>
 <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <4F101047.4090902@broadcom.com>
 <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	"Larry Finger" <Larry.Finger@lwfinger.net>,
	"Alwin Beukers" <alwin@broadcom.com>,
	"Roland Vossen" <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Network Development" <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4508 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755938Ab2ANRhI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jan 2012 12:37:08 -0500
In-Reply-To: <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2012 04:50 AM, Linus Torvalds wrote:
> 2012/1/13 Arend van Spriel <arend@broadcom.com>:
>>
>> Upon suspend my laptop hangs (see trace below pulled from serial
>> console). I do not see the pr_debug in the suspend function (compiled
>> with -DDEBUG). Unfortunately the same happens when I don't insert bcma
>> and brcmsmac. I attached the kernel configuration.
> 
> Ok, I note that you do have MCE enabled.
> 
> The MCE problems should be fixed in current -git, and so it might be
> worth re-testing with that.
> 
>                    Linus
> 

Yep. I disabled it and rebuild a kernel. Unfortunately, during the
weekend I have other obligations. So I can give it a go on monday
morning (amsterdam time).

Gr. AvS
