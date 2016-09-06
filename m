From: Eric Garver <e@erig.me>
Subject: Re: [ovs-dev] [PATCH net-next v21 3/4] openvswitch: 802.1AD Flow
 handling, actions, vlan parsing, netlink attributes
Date: Tue, 6 Sep 2016 08:34:28 -0400
Message-ID: <20160906123428.GL31705@egarver>
References: <1472762727-25844-1-git-send-email-e@erig.me>
 <1472762727-25844-4-git-send-email-e@erig.me>
 <CAOrHB_A6Twwp+S514orUZ5RaKS1hGXgc1uUi7Lj8dxPQrk_sxg@mail.gmail.com>
 <20160903173012.GJ31705@egarver>
 <20160904130546.571fe654@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pravin shelar <pshelar@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Thomas F Herbert <thomasfherbert@gmail.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45870 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754196AbcIFMeh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 08:34:37 -0400
Content-Disposition: inline
In-Reply-To: <20160904130546.571fe654@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 04, 2016 at 01:05:46PM +0200, Jiri Benc wrote:
> On Sat, 3 Sep 2016 13:30:12 -0400, Eric Garver wrote:
> > Would a BUG_ON(!(encap && in_encap)) be better?
> 
> Please don't crash the kernel for something that could very well
> continue without problems. Use WARN_ON at most.

Thanks Jiri. WARN_ON_ONCE() is more appropriate for what I was looking
for.

> And if you go that way, WARN_ON_ONCE or rate limiting seems to be even
> more appropriate, because if this triggers, it's quite possible it will
> trigger repeatedly and the resulting log flood would practically make
> the machine useless anyway.
> 
> Thanks,
> 
>  Jiri
