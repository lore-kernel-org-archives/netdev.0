From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v9 net-next 2/7] net: add low latency socket poll
Date: Wed, 05 Jun 2013 18:31:41 +0300
Message-ID: <51AF59DD.2000901@linux.intel.com>
References: <20130605103400.11172.49099.stgit@ladj378.jer.intel.com> <20130605103421.11172.82925.stgit@ladj378.jer.intel.com> <1370438602.24311.243.camel@edumazet-glaptop> <CA+FuTSevn9Tv41tcoWK7+w6ePEu3woy20GOrWY3rwOPZUhF6kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
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
To: Willem de Bruijn <willemb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+FuTSevn9Tv41tcoWK7+w6ePEu3woy20GOrWY3rwOPZUhF6kQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/06/2013 18:28, Willem de Bruijn wrote:
> On Wed, Jun 5, 2013 at 9:23 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Wed, 2013-06-05 at 13:34 +0300, Eliezer Tamir wrote:
>>> Adds an ndo_ll_poll method and the code that supports it.
>>> This method can be used by low latency applications to busy-poll
>>> Ethernet device queues directly from the socket code.
>>> sysctl_net_ll_poll controls how many microseconds to poll.
>>> Default is zero (disabled).
>>> Individual protocol support will be added by subsequent patches.
>>>
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>> Tested-by: Willem de Bruijn <willemb@google.com>
>>> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>>> ---
>>
>> Are you sure this version was tested by Willem ?
>
> I hadn't tested the latest revisions, indeed. Am testing this one right now.

Sorry, I missed that.
