From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 11/11] asmlinkage, wan/sbni: Make inline assembler symbols
 visible and assembler global
Date: Tue, 22 Oct 2013 19:15:57 -0700
Message-ID: <CAGVrzcZ6xgp4TMgwDFJwz45m8narx0sHYAyM67HsD069tFg3BA@mail.gmail.com>
References: <1382458346-24811-1-git-send-email-andi@firstfloor.org>
 <1382458346-24811-12-git-send-email-andi@firstfloor.org> <20131022.135928.2040131908206663695.davem@davemloft.net>
 <20131023020955.GF29695@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	ak@linux.intel.com, netdev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:42575 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207Ab3JWCQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 22:16:38 -0400
In-Reply-To: <20131023020955.GF29695@two.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/10/22 Andi Kleen <andi@firstfloor.org>:
> On Tue, Oct 22, 2013 at 01:59:28PM -0400, David Miller wrote:
>> From: Andi Kleen <andi@firstfloor.org>
>> Date: Tue, 22 Oct 2013 09:12:26 -0700
>>
>> > From: Andi Kleen <ak@linux.intel.com>
>> >
>> > - Inline assembler defining C callable code has to be global
>> > - The function has to be visible
>> >
>> > Do this in wan/sbni
>> >
>> > Cc: netdev@vger.kernel.org
>> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
>>
>> Is it really impossible to use the generic crc32 support instead of this
>> unsightly custom inline assembler?
>
> Yes it's impossible.
>
> There's no way for me to test it, and this would be a far too big change
> to submit untested.
>
> Also my only interest here is this thing not breaking my LTO
> allyesconfig build. I'm not even sure what it does.
>
> Just because some legacy driver breaks my build you cannot make me
> accountable for maintaining it now.
>
> If it's not possible to get this trivial change in I would need
> to mark it "depends on !LTO" in Kconfig.

How about scheduling the WAN drivers for removal? Does anybody
actually use them nowadays?
--
Florian
