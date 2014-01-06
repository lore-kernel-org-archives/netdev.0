From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: Re: [RFC PATCH net-next 0/4] net_cls for sys container
Date: Mon, 6 Jan 2014 18:06:30 +0800
Message-ID: <52CA8026.4010106@huawei.com>
References: <52C62A44.4070304@huawei.com> <CAM_iQpW0+Ftvk=QBE+0yMNW00VkBee1+yAEmbPkT+zjij9RX-Q@mail.gmail.com> <52CA614D.6040702@huawei.com> <52CA6C80.9060002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Li Zefan <lizefan@huawei.com>,
	Eric Dumazet <edumazet@google.com>, <pshelar@nicira.com>,
	<jasowang@redhat.com>, Simon Horman <horms@verge.net.au>,
	Serge Hallyn <serge.hallyn@ubuntu.com>,
	"Linux Kernel Network Developers" <netdev@vger.kernel.org>,
	<cgroups@vger.kernel.org>, <containers@lists.linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, <xemul@openvz.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Gao feng <gaofeng@cn.fujitsu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52CA6C80.9060002@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




yes
On 2014/1/6 16:42, Gao feng wrote:
> On 01/06/2014 03:54 PM, Libo Chen wrote:
>> On 2014/1/3 13:20, Cong Wang wrote:
>>> On Thu, Jan 2, 2014 at 7:11 PM, Libo Chen <clbchenlibo.chen@huawei.com> wrote:
>>>> Hi guys,
>>>>
>>>> Now, lxc created with veth can not be under control by
>>>> cls_cgroup.
>>>>
>>>> the former discussion:
>>>> http://lkml.indiana.edu/hypermail/linux/kernel/1312.1/00214.html
>>>>
>>>> In short, because cls_cgroup relys classid attached to sock
>>>> filter skb, but sock will be cleared inside dev_forward_skb()
>>>> in veth_xmit().
>>>
>>>
>>> So what are you trying to achieve here?
>>
>> sys container using veth can be controlled by cls_cgroup basing on physic network interface
>>
> 
> It's a problem about virtual nic, not container/net namespace.

yes

> 
> If veth device is running in host. the skb is transmitted firstly by veth device and then delivered
> by physical device. if you set both qdisc rule on veth and physical device. which qdisc rule will take
> effect?

both, the end result depends on a smaller.

> 
> In your patch, both qdisc rule are effective. it looks strange.
> 

qdisc is based nic, does not distinguish virtual or physics. if you are all set,
it means that what you want.  so the logic is not the problemI and this appears to be normal.


thanks,
Libo

> .
> 
