From: =?gb2312?B?0c+6o8ur?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [Patch v3 1/3] ipv4: Namespaceify tcp_fastopen knob
Date: Thu, 21 Sep 2017 09:55:33 +0800
Message-ID: <00D0DCCA-0E9B-4010-BBA0-6D0DDAE7CD46@cmss.chinamobile.com>
References: <1505813896-12121-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <20170920.142227.65942571438912956.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: 8BIT
Cc: kuznet@ms2.inr.ac.ru, edumazet@google.com, weiwan@google.com,
        lucab@debian.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920.142227.65942571438912956.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 2017年9月21日, at 上午5:22, David Miller <davem@davemloft.net> wrote:
> 
> From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> Date: Tue, 19 Sep 2017 17:38:14 +0800
> 
>> -		if ((sysctl_tcp_fastopen & TFO_SERVER_WO_SOCKOPT1) &&
>> -		    (sysctl_tcp_fastopen & TFO_SERVER_ENABLE) &&
>> +		tcp_fastopen =  sock_net(sk)->ipv4.sysctl_tcp_fastopen;
>                              ^^
> 
> Please change that to one space.
> 
> And also please provide an appropriate "[PATCH vX 0/3] " header
> posting when you respin this series.

Sorry, it’s my mistake, thanks David.
> 
>> @@ -282,18 +280,19 @@ struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
>> 	struct tcp_fastopen_cookie valid_foc = { .len = -1 };
>> 	bool syn_data = TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1;
>> 	struct sock *child;
>> +	int tcp_fastopen = sock_net(sk)->ipv4.sysctl_tcp_fastopen;
> 
> Please order local variables from longest to shortest line (aka. reverse
> christmas tree format).
> 

Okay, I’ll take care of such coding style in next commit, thanks!
