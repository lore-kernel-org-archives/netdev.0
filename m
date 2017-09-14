From: =?gb2312?B?0c+6o8ur?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH v2] ipv4: Namespaceify tcp_fastopen knob
Date: Thu, 14 Sep 2017 14:19:20 +0800
Message-ID: <34017292-5BDF-4218-8144-695088D12AF3@cmss.chinamobile.com>
References: <1505301598-12681-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <1505306674.15310.155.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505307779.15310.157.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        Luca BRUNO <lucab@debian.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505307779.15310.157.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 2017年9月13日, at 下午9:02, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> On Wed, 2017-09-13 at 05:44 -0700, Eric Dumazet wrote:
>> On Wed, 2017-09-13 at 19:19 +0800, Haishuang Yan wrote:
>>> Different namespace application might require enable TCP Fast Open
>>> feature independently of the host.
>>> 
>> 
>> Poor changelog, no actual description / list of sysctls that are moved
>> to per netns.
>> 
>> And looking at the patch, it seems your conversion is not complete.
>> 
>> So I will ask you to provide more evidence that you tested your patch
>> next time you submit it.
> 
> I suggest you move one sysctl at a time, in a patch series.
> 
> It will be easier to document and test for you, and review for us.
> 
> Thanks.
> 

Okay, I will split my patch for each sysctl change. Thanks.
