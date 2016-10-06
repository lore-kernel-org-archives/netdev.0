From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 2/3] openvswitch: remove unreachable code in
 vlan parsing
Date: Thu, 6 Oct 2016 11:08:39 +0200
Message-ID: <20161006110839.46c82fc4@griffin>
References: <cover.1475672568.git.jbenc@redhat.com>
        <3b310a67f5a708da69ee3cf617e6cedd52f85842.1475672569.git.jbenc@redhat.com>
        <CAOrHB_B+qUf9zOORG6KOUgew3g4hZxPNiexdMTLvtaCuQQy1oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57222 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966669AbcJFJIn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Oct 2016 05:08:43 -0400
In-Reply-To: <CAOrHB_B+qUf9zOORG6KOUgew3g4hZxPNiexdMTLvtaCuQQy1oQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Oct 2016 22:22:13 -0700, Pravin Shelar wrote:
> User can turn off TX vlan offload for OVS internal device that would
> allow vlan tagged packet with vlan header on the skb-data. This case
> will cause issue here.

Good catch. This is the feedback I hoped for, not the bikesheding about
a value of unused variable :-)

> We could handle this case by not allowing this configuration.

I'm not sure how clean this is but let's try and see if anyone objects.
I'll send v3.

I also noticed we don't set NETIF_F_HW_VLAN_STAG_TX on internal ports.
I'll fix it, too.

Thanks!

 Jiri
