From: Mark Lord <kernel@teksavvy.com>
Subject: Re: asix usb network driver: nfg
Date: Wed, 26 Oct 2011 21:23:15 -0400
Message-ID: <4EA8B283.3010105@teksavvy.com>
References: <4EA89972.5060101@teksavvy.com> <20111026.194045.2019668159403582571.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111026.194045.2019668159403582571.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-10-26 07:40 PM, David Miller wrote:
> From: Mark Lord <kernel@teksavvy.com>
> Date: Wed, 26 Oct 2011 19:36:18 -0400
> 
>> So, the in-kernel asix driver seems badly broken for a lot of hardware,
>> and the vendor driver also has a slight race somewhere that is cured
>> by enabling debug logging.
>>
>> Is there an asix driver maintainer, or anyone else with the time
>> to step up and try to fix these issues?
> 
> The issues you speak of are well known for at least two years but
> nobody wants to work on this.

Okay, that's useful to know.

I think I may be able to get some funding to take a crack at perhaps
figuring out the "DEBUG" race thing in the vendor's copy of the driver,
since that one seems to be in the better shape of the two.

Any strong advance objections to replacing the in-kernel version
with a (fixed) vendor open source version?

It appears that the two share a common heritage, but somewhere along the
line the in-kernel one stopped being maintained as well as the external one.

Assuming I get approval, I'll try and fix the vendor version,
tidy it up to pass checkpatch.pl with flying colours,
and then submit the resulting diff to you.

Hopeless, or would you perhaps accept such a wholesale change?

Thanks David.
