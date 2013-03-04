From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [RFC PATCH 0/5] net: low latency Ethernet device polling
Date: Mon, 04 Mar 2013 10:46:47 +0200
Message-ID: <51345F77.6060503@linux.intel.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com> <51344F54.8060809@gmail.com> <5134592E.6050508@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5134592E.6050508@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>>>
>>
>>
>> A dumb question: is bypassing tcpdump/netfilters/qdisc etc. what we
>> always want? Isn't this a security issue?
>
> We are not bypassing any of the regular stack checks/hooks, we call the
> normal netif_rx_skb().
correction, netif_receive_skb()
