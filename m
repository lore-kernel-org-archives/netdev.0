From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6 1/5]: Fix locking in __qdisc_destroy rcu-callback
Date: Wed, 04 Aug 2004 21:53:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41113EB8.6000809@trash.net>
References: <410FAD44.7020503@trash.net> <20040804093328.4ee56d30.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040804093328.4ee56d30.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>On Tue, 03 Aug 2004 17:20:36 +0200
>Patrick McHardy <kaber@trash.net> wrote:
>  
>
>>I'm not sure if RCU callback can be scheduled while the kernel is
>>
>>running in process context, so this may be unneccessary.
>>    
>>
>
>RCU callbacks run via tasklets, and thus in softirq context,
>thus your locking changes to _bh() are indeed necessary.
>  
>
I meant because in my understanding of RCU the quintescent state is
not reached while the CPU is running kernel code, so the callback can't
be scheduled. A previously scheduled callback should finish before
further kernel code is run in process context.

Regards
Patrick
