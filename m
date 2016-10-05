From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 5 Oct 2016 15:37:17 -0700
Message-ID: <CA+55aFzbHD95PMUk4JQfAVkDDRcwzZ6vfvMR60tZnQNSwkDE6A@mail.gmail.com>
References: <20161005.014437.1946431553783736769.davem@davemloft.net> <20161006092947.25ae781c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Liping Zhang <liping.zhang@spreadtrum.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20161006092947.25ae781c@canb.auug.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 5, 2016 at 3:29 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> I have been carrying the following merge fix patch (for the merge of
> the net-next tree with Linus' tree) for a while now which seems to have
> got missed:

Ugh. It doesn't seem to be a merge error, because that double iph
assignment came from the original patch that introduced this function:
commit ddc8b6027ad0 ("netfilter: introduce nft_set_pktinfo_{ipv4,
ipv6}_validate()").

So I wouldn't call it a merge error - it just looks like a bug in the
network layer. So I'm not going to apply your patch even though it
looks plausible to me, simply because it's outside my area of
expertise.

David? Pablo?

           Linus
