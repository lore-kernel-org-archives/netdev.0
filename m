From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: brcm80211 breakage..
Date: Tue, 31 Jan 2012 20:49:52 +0100
Message-ID: <4F2845E0.40907@broadcom.com>
References: <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
 <20120131120846.GA8799@polaris.bitmath.org>
 <CA+55aFy5-x6Zevga=rX_q+6vsmXFHyMJ+m8YqrqjC6yELqS6mw@mail.gmail.com>
 <4F283C16.5090508@broadcom.com>
 <20120131193608.GA2138@polaris.bitmath.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"John W. Linville" <linville@redhat.com>,
	"Network Development" <netdev@vger.kernel.org>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: "Henrik Rydberg" <rydberg@euromail.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1858 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753506Ab2AaTuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jan 2012 14:50:03 -0500
In-Reply-To: <20120131193608.GA2138@polaris.bitmath.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2012 08:36 PM, Henrik Rydberg wrote:
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
> I guess my first mail never reached the netdev mailinglist. This is
> also a MacbookAir3,1. Booting from EFI looks like this:

It may have. I am not on that particular mailing list (maybe should) and
google did not help me find it. Thanks for the details.

Gr. AvS
