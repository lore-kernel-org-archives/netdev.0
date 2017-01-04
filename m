From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] openvswitch: upcall: Fix vlan handling.
Date: Wed, 4 Jan 2017 18:39:36 +0100
Message-ID: <20170104183936.641518f7@griffin>
References: <1482769887-8022-1-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jarno Rajahalme <jarno@ovn.org>
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50846 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968678AbdADRjj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 12:39:39 -0500
In-Reply-To: <1482769887-8022-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Dec 2016 08:31:27 -0800, Pravin B Shelar wrote:
> Networking stack accelerate vlan tag handling by
> keeping topmost vlan header in skb. This works as
> long as packet remains in OVS datapath. But during
> OVS upcall vlan header is pushed on to the packet.
> When such packet is sent back to OVS datapath, core
> networking stack might not handle it correctly. Following
> patch avoids this issue by accelerating the vlan tag
> during flow key extract. This simplifies datapath by
> bringing uniform packet processing for packets from
> all code paths.

Sorry for the late review, I was off at the end of December. Just
wanted to say that the patch looks great.

Thanks!

 Jiri
