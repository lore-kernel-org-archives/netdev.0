From: =?gb2312?B?0c+6o8ur?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH] ipv4: Namespaceify tcp_fastopen knob
Date: Wed, 13 Sep 2017 16:49:54 +0800
Message-ID: <ECEF4A52-57A3-497E-9A9D-081F137F3BD8@cmss.chinamobile.com>
References: <1505212257-13386-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <20170912.205709.130426973112637232.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: 8BIT
Cc: kuznet@ms2.inr.ac.ru, edumazet@google.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170912.205709.130426973112637232.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 2017年9月13日, at 上午11:57, David Miller <davem@davemloft.net> wrote:
> 
> From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> Date: Tue, 12 Sep 2017 18:30:57 +0800
> 
>> Different namespace application might require enable TCP Fast Open
>> feature independently of the host.
>> 
>> Reported-by: Luca BRUNO <lucab@debian.org>
>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ...
>> diff --git a/samples/bpf/test_ipip.sh b/samples/bpf/test_ipip.sh
>> index 1969254..7bbc521 100755
>> --- a/samples/bpf/test_ipip.sh
>> +++ b/samples/bpf/test_ipip.sh
>> @@ -173,6 +173,8 @@ function cleanup {
>> cleanup
>> echo "Testing IP tunnels..."
>> test_ipip
>> +sleep 1
>> test_ipip6
>> +sleep 1
>> test_ip6ip6
>> echo "*** PASS ***"
> 
> This seems like a completely unrelated change.
> 

Sorry, I make a mistake for including my local test changes in this patch.

I will remove this change in v2 commit. Thanks David for reviewing.
