From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v6 net-next 2/5] net: implement support for low latency
 socket polling
Date: Wed, 29 May 2013 18:01:24 +0300
Message-ID: <51A61844.1010403@linux.intel.com>
References: <20130529063916.27486.3841.stgit@ladj378.jer.intel.com> <20130529063935.27486.18610.stgit@ladj378.jer.intel.com> <1369834647.5109.15.camel@edumazet-glaptop> <51A60A42.20905@linux.intel.com> <CALuTh9EvzhDaqnVV35wytNg6kJhm+HbOjp5tdxWS9bCTVM5YSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: yaniv saar <yaniv.mellanox@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALuTh9EvzhDaqnVV35wytNg6kJhm+HbOjp5tdxWS9bCTVM5YSA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29/05/2013 17:20, yaniv saar wrote:
> Hi Eliezer,
>
> (If I'm too late then a future note...)
> Why make polling a system-wide configuration?
> Wouldn't it make more sense to implement a sock option?
> An even better solution might be aggregation/combination of both types of
> configurations.
>
> -- Yaniv Sa'ar

We plan on adding a socket option in the future.

-Eliezer
