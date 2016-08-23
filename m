From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/sched: Introduce act_iptunnel
Date: Tue, 23 Aug 2016 21:59:16 +0300
Message-ID: <20160823215916.6fd6a57a@halley>
References: <20160822143834.32422-1-amir@vadai.me>
        <20160822143834.32422-4-amir@vadai.me>
        <891dc7d0-80d5-eebf-662d-7ab63718c3bb@mojatatu.com>
        <20160823162141.GC12627@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Amir Vadai <amir@vadai.me>, Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35298 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754624AbcHWS73 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 14:59:29 -0400
Received: by mail-wm0-f68.google.com with SMTP id i5so19319606wmg.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:59:28 -0700 (PDT)
In-Reply-To: <20160823162141.GC12627@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, 23 Aug 2016 19:21:41 +0300 Amir Vadai <amir@vadai.me> wrote:
> On Tue, Aug 23, 2016 at 08:37:07AM -0400, Jamal Hadi Salim wrote:
> > 
> > The noun "ip tunnel" is a little misleading. Unless you can use
> > this for other types of tunnels (ipip, etc). If this is specific
> > for just vxlan and metadata setting then some name like vxlanmeta
> > or something else that signifies both metadata de/encap + vxlan would
> > be helpful.  
> Yeh, this name is not the best...
> The action is not vxlan specific, it should be good for all the
> ip tunnel interfaces that use metadata for the outer headers.
> I will rename it to something like mdtunnel - unless someone has a
> better suggestion.

Well, in bpf we have BPF_FUNC_skb_set_tunnel_key.

How about "action tunnel_key" as the noun?
Another decent alternative might be "action tunnel_info".

Not sure about the verbs though.. "action tunnel_key set/unset"?

Regards,
Shmulik
