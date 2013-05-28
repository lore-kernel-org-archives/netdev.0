From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v5 net-next 1/5] net: add napi_id and hash
Date: Tue, 28 May 2013 16:41:08 +0300
Message-ID: <51A4B3F4.9000006@linux.intel.com>
References: <20130527074351.29882.51106.stgit@ladj378.jer.intel.com>   <20130527074401.29882.98135.stgit@ladj378.jer.intel.com>  <1369700905.3301.499.camel@edumazet-glaptop>  <51A464B9.5080106@linux.intel.com> <1369748280.3301.534.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369748280.3301.534.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28/05/2013 16:38, Eric Dumazet wrote:
> On Tue, 2013-05-28 at 11:03 +0300, Eliezer Tamir wrote:
>
>> With an atomic we don't need the RTNL in any of the napi_id functions.
>> One less thing to worry about when we try to remove the RTNL.
>
> OK but we'll need something to protect the lists against concurrent
> insert/deletes.
>
> A spinlock or a mutex.

OK
