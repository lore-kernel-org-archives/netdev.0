From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net 2/3] openvswitch: fix vlan subtraction from packet
 length
Date: Tue, 11 Oct 2016 13:41:25 -0400
Message-ID: <20161011174125.GY25403@egarver>
References: <cover.1476111550.git.jbenc@redhat.com>
 <310ec523056b4f4747e800333498ef27ad1248aa.1476111550.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pravin shelar <pshelar@ovn.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56682 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752937AbcJKRsR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Oct 2016 13:48:17 -0400
Content-Disposition: inline
In-Reply-To: <310ec523056b4f4747e800333498ef27ad1248aa.1476111550.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2016 at 05:02:43PM +0200, Jiri Benc wrote:
> When the packet has its vlan tag in skb->vlan_tci, the length of the VLAN
> header is not counted in skb->len. It doesn't make sense to subtract it.
> 
> Fixes: 018c1dda5ff1 ("openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink attributes")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Eric Garver <e@erig.me>
