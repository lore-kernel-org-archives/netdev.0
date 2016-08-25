From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH 1/1] netfilter: gre: Use the consitent GRE and PPTP struct
 instead of the structures defined in netfilter
Date: Thu, 25 Aug 2016 21:38:23 +0800
Message-ID: <CA+6hz4ryexSsivvHrstHfevMvJ4bcPTAU6M6VuWXQqorOjUJ+w@mail.gmail.com>
References: <1471618894-10582-1-git-send-email-fgao@ikuai8.com>
 <CA+6hz4piLVv=L03sst56GrOWMST6gTvEF7h4i1jGw0fNw0M8jw@mail.gmail.com> <20160825121650.GA2537@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gao Feng <fgao@ikuai8.com>, Patrick McHardy <kaber@trash.net>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>,
        Philp Prindeville <philipp@redfish-solutions.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160825121650.GA2537@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

inline

On Thu, Aug 25, 2016 at 8:16 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Fri, Aug 19, 2016 at 11:03:46PM +0800, Feng Gao wrote:
>> My email server reports the last same patch email failed to send.
>> So I just sent it again.
>>
>> I am sorry, if anyone receives duplicated ones.
>
> git am v2-1-2-net-next-netfilter-gre-Use-consistent-GRE_-macros-instead-of-ones-defined-by-netfilter..patch
> -s
> Applying: netfilter: gre: Use consistent GRE_* macros instead of ones
> defined by netfilter.
> error: patch failed: include/uapi/linux/if_tunnel.h:36
> error: include/uapi/linux/if_tunnel.h: patch does not apply
>
> It seems your base was missing this patch:
>
> commit ab10dccb11608b96b43b557c12a5ad867723e503
> Author: Gao Feng <fgao@ikuai8.com>
> Date:   Tue Aug 9 12:38:24 2016 +0800
>
>     rps: Inspect PPTP encapsulated by GRE to get flow hash
>
> Since I cannot see GRE_FLAGS in your patch as context.

Oh, it is possible that the patches are generated based on my local
branch which has this commit locally, not the latest net-next.
Now, I am more familiar with the rules than before.

>
> Please rebase and resubmit, thanks!

Ok, I will resubmit. Sorry for this fault.

Regards
Feng
