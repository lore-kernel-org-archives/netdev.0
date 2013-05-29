From: yaniv saar <yaniv.mellanox@gmail.com>
Subject: Re: [PATCH v6 net-next 2/5] net: implement support for low latency
 socket polling
Date: Wed, 29 May 2013 17:40:02 +0300
Message-ID: <CALuTh9EcKCgx3pktq7FXkojhDxKn580csJV-u3BBokhhY2SrSg@mail.gmail.com>
References: <20130529063916.27486.3841.stgit@ladj378.jer.intel.com>
	<20130529063935.27486.18610.stgit@ladj378.jer.intel.com>
	<CAJZOPZJqF1FTLH3a3ZKUTA4ViesAZEkRi=dgd-ux8eRu9TyhBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJZOPZJqF1FTLH3a3ZKUTA4ViesAZEkRi=dgd-ux8eRu9TyhBw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eliezer,

(If I'm too late then a future note...)
Why make polling a system-wide configuration?
Wouldn't it make more sense to implement a sock option?
An even better solution might be aggregation/combination of both types
of configurations.

-- Yaniv Sa'ar


On Wed, May 29, 2013 at 5:14 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Wed, May 29, 2013 at 9:39 AM, Eliezer Tamir
> <eliezer.tamir@linux.intel.com> wrote:
>> Adds a new ndo_ll_poll method and the code that supports and uses it.
>> This method can be used by low latency applications to busy poll Ethernet
>> device queues directly from the socket code. The value of sysctl_net_ll_poll
>> controls how many microseconds to poll. Set to zero to disable.
>
> Unlike with TCP sockets, UDP sockets may receive packets from multiple
> sources and hence the receiving context may be steered to be executed
> on different cores through RSS or other Flow-Steering HW mechanisms
> which could mean different napi contexts for the same socket, is that
> a problem here? what's the severity?
>
> Or.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
