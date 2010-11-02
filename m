From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [Security] [SECURITY] CAN info leak/minor heap overflow
Date: Tue, 02 Nov 2010 21:19:14 +0100
Message-ID: <4CD07242.8080509@hartkopp.net>
References: <1288722503.2504.14.camel@dan> <4CD069D4.7010801@hartkopp.net> <1288727605.2504.21.camel@dan> <AANLkTi=EcAQ0u_wYAnVkvV_Ve9in4z2Es5h1pBbyMeXe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, netdev@vger.kernel.org,
	security@kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:44212 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab0KBUTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 16:19:19 -0400
In-Reply-To: <AANLkTi=EcAQ0u_wYAnVkvV_Ve9in4z2Es5h1pBbyMeXe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.11.2010 20:57, Linus Torvalds wrote:
> On Tue, Nov 2, 2010 at 3:53 PM, Dan Rosenberg <drosenberg@vsecurity.com> wrote:
>>
>>> Why is this bad? Can the addresses of CAN-BCM sock structs be used for
>>> anything from userspace?
>>>
>>> For me they are just intented to be unique numbers ...
>>>
>>
>> This is a bad idea because it makes exploiting other kernel
>> vulnerabilities easier.  Exposing the address of an object in a slab
>> cache, especially an object that unprivileged users have some level of
>> control of, is just an invitation to use that structure when writing
>> exploits, for heap overflows or otherwise.
> 
> Indeed. At the very least, hash them and truncate them with some
> secret per-boot value or something. Even better, use something like a
> socket number so that maybe they can be associated with
> /proc/<xyz>/fd/<x> or other system info if somebody were to care.

Good hint!

Will pick this idea.

Thanks,
Oliver
