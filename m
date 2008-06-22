From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 00/25] Conntracking and NAT in netns
Date: Sun, 22 Jun 2008 23:41:56 +0200
Message-ID: <485EC724.1030005@fr.ibm.com>
References: <20080622005916.GA5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, den@openvz.org, xemul@openvz.org,
	ebiederm@xmission.com, benjamin.thery@bull.net
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080622005916.GA5392@martell.zuzino.mipt.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Hi, patchbomb below makes significant parts of connection tracking and
> NAT code usable in netns and independent from other netns.
> 
> Status is that it is lightly tested but more or less works, I used it on
> a box which provides NAT for another with all netdevices moved to netns,
> routing and iptables rules set up and rules flushed in init_net.
> 
> So far so good.
> 
> Weak points:
> a) races during netns destruction or conntrack modules unload
>    (see more in patches)
> b) grabbing netns from skb->dev or skb->dst->dev
>    these places should be checked with extreme scrunity :-\
> c) some stuff not converted (pptp, h323) -- it's like 10 minutes to make
>    a patch and full day to setup and test it :^)
> d) IPv6 conntracking wasn't tested.
> e) ordering probably should be redone (or it shouldn't since netfilter
>    is banned in netns as is, so nobody will care)

You describe this patchset as no finished and there is a patch to not be 
applied, shall I assume it is a RFC ?

In any case, thanks Alexey for this patchset, I will it review tomorrow.

   -- Daniel
