From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH net-next 0/4] net_cls for sys container
Date: Mon, 6 Jan 2014 15:54:53 +0800
Message-ID: <52CA614D.6040702@huawei.com>
References: <52C62A44.4070304@huawei.com> <CAM_iQpW0+Ftvk=QBE+0yMNW00VkBee1+yAEmbPkT+zjij9RX-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	<jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>,
	Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	"Linux Kernel Network Developers" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAM_iQpW0+Ftvk=QBE+0yMNW00VkBee1+yAEmbPkT+zjij9RX-Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2014/1/3 13:20, Cong Wang wrote:
> On Thu, Jan 2, 2014 at 7:11 PM, Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> wrote:
>> Hi guys,
>>
>> Now, lxc created with veth can not be under control by
>> cls_cgroup.
>>
>> the former discussion:
>> http://lkml.indiana.edu/hypermail/linux/kernel/1312.1/00214.html
>>
>> In short, because cls_cgroup relys classid attached to sock
>> filter skb, but sock will be cleared inside dev_forward_skb()
>> in veth_xmit().
> 
> 
> So what are you trying to achieve here?

sys container using veth can be controlled by cls_cgroup basing on physic network interface

thanks,
Libo

> 
> .
> 
