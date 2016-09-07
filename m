From: hejianet <hejianet@gmail.com>
Subject: Re: [RFC PATCH v2 0/6] Reduce cache miss for snmp_fold_field
Date: Wed, 7 Sep 2016 10:30:59 +0800
Message-ID: <beb30504-7c22-482d-330a-469ad3232e8e@gmail.com>
References: <1473129009-20478-1-git-send-email-hejianet@gmail.com>
 <20160906124413.GC27658@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160906124413.GC27658@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcelo

Thanks for the suggestion

Will consider that

B.R.

Jia


On 9/6/16 8:44 PM, Marcelo Ricardo Leitner wrote:
> On Tue, Sep 06, 2016 at 10:30:03AM +0800, Jia He wrote:
> ...
>> v2:
>> - 1/6 fix bug in udplite statistics.
>> - 1/6 snmp_seq_show is split into 2 parts
>>
>> Jia He (6):
>>    proc: Reduce cache miss in {snmp,netstat}_seq_show
>>    proc: Reduce cache miss in snmp6_seq_show
>>    proc: Reduce cache miss in sctp_snmp_seq_show
>>    proc: Reduce cache miss in xfrm_statistics_seq_show
>>    ipv6: Remove useless parameter in __snmp6_fill_statsdev
>>    net: Suppress the "Comparison to NULL could be written" warning
> Hi Jia,
>
> Did you try to come up with a generic interface for this, like
> snmp_fold_fields64() (note the fieldS) or snmp_fold_field64_batch() ?
>
> Sounds like we have the same code in several places and seems they all
> operate very similarly. They have a percpu table, an identified max, a
> destination buffer..
>
> If this is possible, this would reduce the possibility of hiccups in a
> particular code.
>
>    Marcelo
>
>
