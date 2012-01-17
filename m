From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Tue, 17 Jan 2012 11:37:13 +0100
Message-ID: <4F154F59.4060300@broadcom.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com>
 <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <4F101047.4090902@broadcom.com>
 <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
 <4F142D84.4060405@broadcom.com> <4F145F52.9010200@broadcom.com>
 <CA+55aFyMY5o7irG+=c4ZrfftMu6OJvoyFFY4KNO8rCe90P0mhw@mail.gmail.com>
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
Received: from mms3.broadcom.com ([216.31.210.19]:1049 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988Ab2AQKh0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 05:37:26 -0500
In-Reply-To: <CA+55aFyMY5o7irG+=c4ZrfftMu6OJvoyFFY4KNO8rCe90P0mhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2012 02:12 AM, Linus Torvalds wrote:
> 2012/1/16 Arend van Spriel <arend@broadcom.com>:
>>
>> I build a new kernel with MCE enabled. Same issue. I did not load bcma
>> or brcmsmac yet. Attached is trace I could pull from the kernel log
>> (str-test-*).
> 
> Oh well. Everything looks fine in the test traces - the warnings are
> annoying and nasty, but a known issue and not dangerous (and I have a
> patch in my tree to fix them now).
> 
> So if the real suspend fails, it's some other subsystem that has
> gotten broken. I don't think I have any other reports like that yet,
> and there is not a lot to go on. If you could try to bisect it (I
> assume plain Linux-3.2 works fine?) that woudl be wonderful, otherwise
> I think we're stuck waiting for somebody else to hit it and figure it
> out.
> 
>                  Linus
> 

I am going to give the bisect a try. Hopefully (not likely) it will take
not too many steps.

Gr. AvS
