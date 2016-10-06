From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Wed, 05 Oct 2016 20:26:24 -0400 (EDT)
Message-ID: <20161005.202624.1436239748210168011.davem@davemloft.net>
References: <20161006092947.25ae781c@canb.auug.org.au>
        <CA+55aFzbHD95PMUk4JQfAVkDDRcwzZ6vfvMR60tZnQNSwkDE6A@mail.gmail.com>
        <20161006000945.GA18976@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, sfr@canb.auug.org.au,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, liping.zhang@spreadtrum.com
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161006000945.GA18976@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 6 Oct 2016 02:09:45 +0200

> On Wed, Oct 05, 2016 at 03:37:17PM -0700, Linus Torvalds wrote:
>> On Wed, Oct 5, 2016 at 3:29 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>> >
>> > I have been carrying the following merge fix patch (for the merge of
>> > the net-next tree with Linus' tree) for a while now which seems to have
>> > got missed:
>> 
>> Ugh. It doesn't seem to be a merge error, because that double iph
>> assignment came from the original patch that introduced this function:
>> commit ddc8b6027ad0 ("netfilter: introduce nft_set_pktinfo_{ipv4,
>> ipv6}_validate()").
>> 
>> So I wouldn't call it a merge error - it just looks like a bug in the
>> network layer. So I'm not going to apply your patch even though it
>> looks plausible to me, simply because it's outside my area of
>> expertise.
>> 
>> David? Pablo?
> 
> This looks good, please take it so we speed up things.
> 
> Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied.
