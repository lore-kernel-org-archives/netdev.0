From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 22:01:13 +0100
Message-ID: <4F0DF899.8010101@broadcom.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com>
 <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Network Development" <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"=?ISO-8859-2?Q?Rafa=B3_?= =?ISO-8859-2?Q?Mi=B3ecki?="
	<zajec5@gmail.com>, "Larry Finger" <Larry.Finger@lwfinger.net>
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4129 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146Ab2AKVBf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 16:01:35 -0500
In-Reply-To: <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2012 05:04 PM, Linus Torvalds wrote:
> On Wed, Jan 11, 2012 at 7:05 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> Sadly, that one makes no difference. I'll enable BRCM/BCMA debugging
>> and see if that gives any more information, but will be unable to do
>> much for the next few hours, so it will likely not be until this
>> afternoon.

There goes my theory. I have no MacBook Air over here and we have
nightly testing running for this chip. I will have it run on your branch
iso wireless to see if I can reproduce it over here.

> Ok, could do it now. But that really doesn't give much more
> information. Here it is anyway:
> [   41.797178] brcmsmac bcma0:0: mfg 4bf core 812 rev 23 class 0 irq 17
> [   41.952030] bcma: Switched to core: 0x820
> [   41.952050] bcma: Switched to core: 0x800
> [   41.953881] ieee80211 phy0: wl0: brcms_b_attach: si_attach failed
> [   41.956397] ieee80211 phy0: wl0: brcms_b_attach: failed with err 11
> [   41.958443] ieee80211 phy0: wl0: brcms_c_attach: failed with err 11
> [   41.960468] ieee80211 phy0: brcmsmac: attach() failed with code 11
> [   41.962316] brcmsmac: brcms_bcma_probe: brcms_attach failed!
> [   41.967275] brcms_module_init: register returned 0
> 
> hopefully this gives people *some* idea, but I'm not seeing anything.
> 
>          Linus
> 

I have some idea, but no success in reproducing it. Could you provide
the .config used on this?

Gr. AvS
