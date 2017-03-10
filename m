From: Jonathan Maxwell <jmaxwell37@gmail.com>
Subject: Re: [PATCH net, v1] dccp/tcp: fix routing redirect race
Date: Fri, 10 Mar 2017 16:05:19 +1100
Message-ID: <CAGHK07Cd8e6eDc2hRR6DL77PvFtFPSW2TJzvYf5PO8n38ThvqQ@mail.gmail.com>
References: <1489116691-26264-1-git-send-email-jmaxwell37@gmail.com> <1489119824.28631.26.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: gerrit@erg.abdn.ac.uk, David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        kuznet <kuznet@ms2.inr.ac.ru>, jmorris <jmorris@namei.org>,
        yoshfuji <yoshfuji@linux-ipv6.org>, kaber <kaber@trash.net>,
        Neal Cardwell <ncardwell@google.com>, dccp@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jon Maxwell <jmaxwell@redhat.com>,
        Eric Garver <egarver@redhat.com>,
        Hannes Sowa <hsowa@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489119824.28631.26.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 10, 2017 at 3:23 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2017-03-10 at 14:31 +1100, Jon Maxwell wrote:
>> As Eric Dumazet pointed out this also needs to be fixed in IPv6.
>> v1: Contains the IPv6 patch as well.
>
>> Fixes: ceb3320610d6 ("ipv4: Kill routes during PMTU/redirect updates.")
>> Cc: Eric Garver <egarver@redhat.com>
>> Cc: Hannes Sowa <hsowa@redhat.com>
>> Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
>> ---
>>  net/dccp/ipv4.c     | 3 ++-
>>  net/ipv4/tcp_ipv4.c | 3 ++-
>>  net/ipv6/tcp_ipv6.c | 8 +++++---
>
> Hi Jon.
>
> You forgot net/dccp/ipv6.c
>
> dccp_v6_err() has the same issue.
>
>

Thanks Eric,

My bad. I'll fix that and post another patch.
