From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/4] net: implement support for low latency
 socket polling
Date: Mon, 20 May 2013 12:34:40 -0700 (PDT)
Message-ID: <20130520.123440.567878984450788905.davem@davemloft.net>
References: <20130519102533.12527.12991.stgit@ladj378.jer.intel.com>
	<20130520.005447.972811583292360876.davem@davemloft.net>
	<5199EF6F.9040008@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	andi@firstfloor.org, hpa@zytor.com, eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5199EF6F.9040008@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Mon, 20 May 2013 12:39:59 +0300

> On 20/05/2013 10:54, David Miller wrote:
>> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>> Date: Sun, 19 May 2013 13:25:33 +0300
>>
>>> +#else /* CONFIG_INET_LL_RX_FLUSH */
>>> +
>>> +#define sk_valid_ll(sk) 0
>>> +#define sk_poll_ll(sk, nonblock) do {} while (0)
>>> +#define skb_mark_ll(napi, skb) do {} while (0)
>>> +#define sk_mark_ll(sk, skb) do {} while (0)
>>
>> Make these inline functions too, so that even if
>> CONFIG_INET_LL_RX_POLL is disabled, the arguments and return values
>> are still properly type checked.
> 
> Is this what you had in mind?
> 
> static inline bool sk_valid_ll(struct sock *sk)

Yes.
