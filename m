From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: brcm80211 breakage..
Date: Tue, 31 Jan 2012 20:35:08 +0100
Message-ID: <4F28426C.8090300@broadcom.com>
References: <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
 <20120131120846.GA8799@polaris.bitmath.org>
 <CA+55aFy5-x6Zevga=rX_q+6vsmXFHyMJ+m8YqrqjC6yELqS6mw@mail.gmail.com>
 <4F283C16.5090508@broadcom.com> <20120131192520.GA2974@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"Henrik Rydberg" <rydberg@euromail.se>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"John W. Linville" <linville@redhat.com>,
	"Network Development" <netdev@vger.kernel.org>,
	"=?ISO-8859-2?Q?Rafa=B3_M?= =?ISO-8859-2?Q?i=B3ecki?="
	<zajec5@gmail.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4752 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753876Ab2AaTfT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jan 2012 14:35:19 -0500
In-Reply-To: <20120131192520.GA2974@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2012 08:25 PM, John W. Linville wrote:
> On Tue, Jan 31, 2012 at 08:08:06PM +0100, Arend van Spriel wrote:
>> On 01/31/2012 06:02 PM, Linus Torvalds wrote:
>>> On Tue, Jan 31, 2012 at 4:08 AM, Henrik Rydberg <rydberg@euromail.se> wrote:
>>>>
>>>> probing simply fails on my machine,
>>>>
>>>> [  882.064120] bcma: Failed to get SPROM: -71
>>>> [  882.064256] bcma-pci-bridge: probe of 0000:01:00.0 failed with error -2
>>>>
>>>> resulting in no wireless. Since the bcma SPROM setup allegedly is
>>>> unused, simply ignoring the error with this hack
>>>
>>> I personally hit the "No SPROM available" case, which is apparently
>>> why it works for me.
>>>
>>> That said, I obviously agree with your patch: if we don't fail for the
>>> "No SPROM available" case, then we damn well shouldn't fail just
>>> because it *is* available but we can't read it or whatever.
>>>
>>> So Ack on the patch from me, but it should go through the network
>>> guys. Arend, John?
>>>
>>
>> The SPROM code in bcma needs some attention, because the availability of
>> it depends between chipsets. I think in bcma not all variations are
>> known and thus lacking implementation to handle those. So ultimately
>> bcma sprom code needs to be extended (looking at brcmsmac code). The
>> sprom code in brcmsmac can go when that has happened.
>>
>> I will dive into that. I have not hit the "Failed to get SPROM" case so
>> any chipset info would be appreciated (Henrik?).
> 
> Making the SPROM code be better informed sounds great.  In the
> meantime, Henrik's patch seems reasonable.  Any objections?
> 

Yeah. Forgot to mention, but as it does not break stuff Ack from me.

Gr. AvS
