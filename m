From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v3 net-next 3/3] openvswitch: Fix skb->protocol for vlan
 frames.
Date: Fri, 2 Dec 2016 10:49:36 +0100
Message-ID: <20161202104936.09ad1af3@griffin>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
        <1480462253-114713-3-git-send-email-jarno@ovn.org>
        <20161130153041.7a9590ef@griffin>
        <CAOrHB_CAR8G=BF6X_+HgkRRnb=Erc6CYpCL4EnJfDRe7qBR2vg@mail.gmail.com>
        <20161202104202.426b2c80@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarno Rajahalme <jarno@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54972 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751786AbcLBJtk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 04:49:40 -0500
In-Reply-To: <20161202104202.426b2c80@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Dec 2016 10:42:02 +0100, Jiri Benc wrote:
> On Thu, 1 Dec 2016 12:31:09 -0800, Pravin Shelar wrote:
> It's not set exactly by the caller, because that's what this patch is
> removing. It is set by whoever handed over the packet to openvswitch.
> The point is we don't know *what* it is set to. It may as well be
> ETH_P_8021Q, breaking the conditions here. It should not happen in
> practice but still, it seems weird to depend on the fact that the
> packet coming to ovs has never skb->protocol equal to ETH_P_8021Q nor
> ETH_P_8021AD.

I'm wondering whether we should not revive the patchset that makes the
first vlan tag always accelerated. It makes handling of various packet
formats and the checks for forwardability so much simpler...

 Jiri
