From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: [PATCH net] netfilter: xt_TCPMSS: add more sanity tests on
 tcph->doff
Date: Thu, 20 Apr 2017 21:14:55 +0300
Message-ID: <57943637ed28d314172e2a9ad0f4d99f@nuclearcat.com>
References: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
 <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <1491242111.10124.32.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170408202443.GA3373@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170408202443.GA3373@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-04-08 23:24, Pablo Neira Ayuso wrote:
> On Mon, Apr 03, 2017 at 10:55:11AM -0700, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> Denys provided an awesome KASAN report pointing to an use
>> after free in xt_TCPMSS
>> 
>> I have provided three patches to fix this issue, either in xt_TCPMSS 
>> or
>> in xt_tcpudp.c. It seems xt_TCPMSS patch has the smallest possible
>> impact.
> 
> Applied to nf.git, thanks!
Any plans to queue it to stable trees?
It seems affected kernel for years.
