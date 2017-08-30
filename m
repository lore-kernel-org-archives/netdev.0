From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next 0/4] nsh: headers, GSO
Date: Wed, 30 Aug 2017 13:23:04 +0800
Message-ID: <20170830052303.GA109175@cran64.bj.intel.com>
References: <cover.1503948295.git.jbenc@redhat.com>
 <20170829.151707.1911972805135395713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jbenc@redhat.com" <jbenc@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "e@erig.me" <e@erig.me>,
        "jan.scheurich@ericsson.com" <jan.scheurich@ericsson.com>,
        "blp@ovn.org" <blp@ovn.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21333 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750749AbdH3Fht (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 01:37:49 -0400
Content-Disposition: inline
In-Reply-To: <20170829.151707.1911972805135395713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 30, 2017 at 06:17:07AM +0800, David Miller wrote:
> From: Jiri Benc <jbenc@redhat.com>
> Date: Mon, 28 Aug 2017 21:43:20 +0200
> 
> > This adds header structs and helpers for NSH together with GSO support.
> > 
> > Note there is no code in this patchset that actually manipulates the NSH
> > headers. That was sent to netdev by Yi Yang ("[PATCH net-next v6 0/3]
> > openvswitch: add NSH support"). The aim of this series is to lay the
> > groundwork and ease the implementation for him.
> > 
> > In addition to openvswitch, the NSH support should be added to tc (flower to
> > match, act_nsh to push/pop NSH headers). That will come later. There's
> > currently no plan to support NSH by other means than those two.
> > 
> > The patch 3 in this patchset was written by Yi Yang, I took it from the
> > aforementioned series and slightly modified it - see the note in the patch.
> 
> Series applied, thanks Jiri.

Hi, Jiri

David has merged your NSH GSO series, do you have one more patch series
to fix VxLAN-gpe+NSH GSO issue? I think we still need do something in
skb_udp_tunnel_segment in net/ipv4/udp_offload.c to support
VxLAN-gpe+NSH GSO.

I'll post new OVS NSH kernel datapath patch series if NSH GSO is done.
