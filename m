From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 4/4] Netfilter: xt_LOG: Implement ring buffer support
Date: Wed, 08 Feb 2012 11:40:03 +0100
Message-ID: <4F325103.4000908@nod.at>
References: <1328400892-22409-1-git-send-email-richard@nod.at> <1328400892-22409-7-git-send-email-richard@nod.at> <20120208102914.GA32092@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, rostedt@goodmis.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120208102914.GA32092@1984>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08.02.2012 11:29, Pablo Neira Ayuso wrote:
> On Sun, Feb 05, 2012 at 01:14:52AM +0100, Richard Weinberger wrote:
>> This patch introduces NETFILTER_XT_TARGET_LOG_RING.
>> It allows logging into various ring buffers which are
>> represented as pipe-like files in /proc/net/netfilter/xt_LOG_ring/.
>>
>> Signed-off-by: Richard Weinberger<richard@nod.at>
>> ---
>>   include/linux/netfilter/xt_LOG.h    |   13 +-
>>   include/net/netfilter/nf_log.h      |    1 +
>>   include/net/netfilter/xt_log_ring.h |   24 +
>>   net/netfilter/Kconfig               |   13 +
>>   net/netfilter/Makefile              |    2 +
>>   net/netfilter/xt_LOG.c              |  921 -----------------------------
>>   net/netfilter/xt_LOG_core.c         | 1108 +++++++++++++++++++++++++++++++++++
>>   net/netfilter/xt_LOG_ring.c         |  430 ++++++++++++++
>
> Can you avoid this rename and splitting LOG into two files? I prefer
> having everything into the same file xt_LOG.c.

Sure, I'll merge it into one file.

I made the split to keep xt_LOG_core.c clean.
99% of xt_LOG_ring.c has nothing to do with netfilter and is just
ring_buffer and proc stuff.

> Apart from that, this looks fine to me.

:-)

Thanks,
//richard
