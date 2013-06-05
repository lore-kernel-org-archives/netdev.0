From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH v9 net-next 2/7] net: add low latency socket poll
Date: Wed, 5 Jun 2013 11:28:24 -0400
Message-ID: <CA+FuTSevn9Tv41tcoWK7+w6ePEu3woy20GOrWY3rwOPZUhF6kQ@mail.gmail.com>
References: <20130605103400.11172.49099.stgit@ladj378.jer.intel.com>
 <20130605103421.11172.82925.stgit@ladj378.jer.intel.com> <1370438602.24311.243.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370438602.24311.243.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 5, 2013 at 9:23 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-06-05 at 13:34 +0300, Eliezer Tamir wrote:
>> Adds an ndo_ll_poll method and the code that supports it.
>> This method can be used by low latency applications to busy-poll
>> Ethernet device queues directly from the socket code.
>> sysctl_net_ll_poll controls how many microseconds to poll.
>> Default is zero (disabled).
>> Individual protocol support will be added by subsequent patches.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Tested-by: Willem de Bruijn <willemb@google.com>
>> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>> ---
>
> Are you sure this version was tested by Willem ?

I hadn't tested the latest revisions, indeed. Am testing this one right now.

> Acked-by: Eric Dumazet <edumazet@google.com>
>
>
>
