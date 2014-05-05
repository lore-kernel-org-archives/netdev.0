From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] netdev: pktgen xmit packet through vlan interface
Date: Mon, 05 May 2014 09:24:13 -0700
Message-ID: <5367BB2D.4080907@candelatech.com>
References: <1399015092-28643-1-git-send-email-zhouzhouyi@gmail.com> <20140502151921.014fbeec@redhat.com> <5363A4E0.2000403@intel.com> <20140505171252.49773a5a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Zhouyi Zhou <zhouzhouyi@gmail.com>, davem@davemloft.net,
	steffen.klassert@secunet.com, fan.du@windriver.com,
	dborkman@redhat.com, minipli@googlemail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140505171252.49773a5a@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/05/2014 08:12 AM, Jesper Dangaard Brouer wrote:
> On Fri, 02 May 2014 07:00:00 -0700
> John Fastabend <john.r.fastabend@intel.com> wrote:
> 
>> On 5/2/2014 6:19 AM, Jesper Dangaard Brouer wrote:
>>> On Fri,  2 May 2014 15:18:12 +0800
>>> Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
>>>
>>>> As http://www.spinics.net/lists/netdev/msg165015.html
>>>> pktgen generates shared packet through vlan interface will cause
>>>> oops because of duplicate entering tc queue.
>>>>
>>>> Try to solve this problem by means of packet clone instead of sharing.
>>>
>>> I really don't like adding this stuff to the fast path of pktgen.
>>>
>>> Why would you use pktgen on a VLAN?
>>
>> Its a good way to test qdiscs. When you run pktgen over the VLAN
>> you exercise the lower devices qdisc.
> 
> I do (personally) need a faster way/tool to exercise the qdisc path.
> I'm currently using trafgen, but it is not fast enough for my 10G
> testing.
> 
> Perhaps we could add a pktgen option, that explicitly enable
> transmitting on qdisc path.  And when adding a VLAN device, auto enable
> that mode?

You could just force pktgen to not support multi-skb on vlan interfaces?

I thought we went through this a year or two ago and came up with
something like a 'pktgen-challenged' network interface flag?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
