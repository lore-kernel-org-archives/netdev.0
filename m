From: Greg KH <gregkh@suse.de>
Subject: Re: [patch net-2.6] vlan: reset headers on accel emulation path
Date: Thu, 18 Aug 2011 11:16:53 -0700
Message-ID: <20110818181653.GA18213@suse.de>
References: <1313685345-2417-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43771 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751206Ab1HRSZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2011 14:25:28 -0400
Content-Disposition: inline
In-Reply-To: <1313685345-2417-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 18, 2011 at 06:35:45PM +0200, Jiri Pirko wrote:
> It's after all necessary to do reset headers here. The reason is we
> cannot depend that it gets reseted in __netif_receive_skb once skb is
> reinjected. For incoming vlanids without vlan_dev, vlan_do_receive()
> returns false with skb != NULL and __netif_reveive_skb continues, skb is
> not reinjected.
> 
> This might be good material for 3.0-stable as well

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
