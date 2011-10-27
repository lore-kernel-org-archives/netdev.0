From: Mark Lord <kernel@teksavvy.com>
Subject: Re: asix usb network driver: nfg
Date: Thu, 27 Oct 2011 14:48:03 -0400
Message-ID: <4EA9A763.3000607@teksavvy.com>
References: <4EA89972.5060101@teksavvy.com> <20111026.194045.2019668159403582571.davem@davemloft.net> <4EA8B283.3010105@teksavvy.com> <20111026.221719.2216112919297458522.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111026.221719.2216112919297458522.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-10-26 10:17 PM, David Miller wrote:
> From: Mark Lord <kernel@teksavvy.com>
> Date: Wed, 26 Oct 2011 21:23:15 -0400
> 
>> Any strong advance objections to replacing the in-kernel version
>> with a (fixed) vendor open source version?
> 
> It need to meet the coding etc. standards for inclusion, last
> time I looked at it their driver indeed need a bit of cleaning up.

Yeah, okay -- I've got approval to spend some paid time on the effort,
so I'll have a deeper look at things.

> It's a sad situation, they started with the upstream driver and
> just hacked on it however they pleased in their private copy.
> So now we have this huge divergance and no effort on their part
> to rectify things.

Will there be any issues with "Signed-Off-By" on this?
It's all GPL, by License, but we don't necessarily know who
make what changes to their driver since they forked it.
I don't think that matters much, but then what I think doesn't matter much
either. :)

But it is the only one of the two that's close to working
(and does work when DEBUG messages are enabled -- a timing issue
somewhere that I'll fix).

Thanks David.
