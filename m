From: hejianet <hejianet@gmail.com>
Subject: Re: [RFC PATCH 1/6] proc: Reduce cache miss in
 {snmp,netstat}_seq_show
Date: Tue, 30 Aug 2016 16:15:36 +0800
Message-ID: <0c4f4f45-ec27-d1d3-45f8-a7ed8a4ca667@gmail.com>
References: <1472486640-1111-1-git-send-email-hejianet@gmail.com>
 <1472486640-1111-2-git-send-email-hejianet@gmail.com>
 <1472488885.14381.260.camel@edumazet-glaptop3.roam.corp.google.com>
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
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472488885.14381.260.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric


On 8/30/16 12:41 AM, Eric Dumazet wrote:
> On Tue, 2016-08-30 at 00:03 +0800, Jia He wrote:
>> This patch exchanges the two loop for collecting the percpu statistics
>> data. This can aggregate the data by going through all the items of each
>> cpu sequentially. In snmp_seq_show, just use one buff copy to dislay the
>> Udp and UdpLite data because they are the same.
> This is obviously not true.
>
> On my laptop it seems it handled no UdpLite frames, but got plenty of
> Udp ones.
>
> $ grep Udp /proc/net/snmp
> Udp: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors SndbufErrors InCsumErrors
> Udp: 1555889 108318 0 3740780 0 0 0
> UdpLite: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors SndbufErrors InCsumErrors
> UdpLite: 0 0 0 0 0 0 0
Thanks, you are right. I misunderstand the comments of source codes.
Will resend it

B.R.
Jia
>
>
>
> .
>
