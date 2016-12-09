From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v3 net-next 2/3] openvswitch: Use is_skb_forwardable()
 for length check.
Date: Fri, 9 Dec 2016 09:49:02 +0100
Message-ID: <20161209094902.09580191@griffin>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
        <1480462253-114713-2-git-send-email-jarno@ovn.org>
        <20161130145159.3cee7ba4@griffin>
        <CAOrHB_BEQBbvDa2W0dJmmANsjZEiwx7GbTxo-7yirDB=5d9cqQ@mail.gmail.com>
        <20161202102509.065df1e8@griffin>
        <CAOrHB_BTRP69VDeA2_cSf_qKh05Wj=OinaqU3Uu=52Wus6xS8w@mail.gmail.com>
        <20161208205040.GJ18719@wsfd-netdev-buildsys.lab.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pravin Shelar <pshelar@ovn.org>, Jarno Rajahalme <jarno@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39752 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752819AbcLIItF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Dec 2016 03:49:05 -0500
In-Reply-To: <20161208205040.GJ18719@wsfd-netdev-buildsys.lab.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Dec 2016 15:50:41 -0500, Eric Garver wrote:
> Should we not also follow the "skbs are untagged" approach that the rest
> of the kernel uses? I'm referring to patches 1 and 2 form Jiri's series
> "openvswitch: make vlan handling consistent".
> 
> With those changes is_skb_forwardable() would behave as expected here.

Yes, this would make the check easy and consistent (and was actually my
original motivation for the mentioned patchset).

Still, is_skb_forwardable would be off by 4 bytes. I wonder whether
it's not off even for the bridge case. And dev_forward_skb seems to be
fishy, too.

 Jiri
