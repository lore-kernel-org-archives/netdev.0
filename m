From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] bonding: move processing of recv handlers
 into handle_frame()
Date: Mon, 25 Apr 2011 12:00:44 -0700 (PDT)
Message-ID: <20110425.120044.71103531.davem@davemloft.net>
References: <1303220896-9092-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47811
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758667Ab1DYTBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 15:01:18 -0400
In-Reply-To: <1303220896-9092-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 19 Apr 2011 15:48:16 +0200

> Since now when bonding uses rx_handler, all traffic going into bond
> device goes thru bond_handle_frame. So there's no need to go back into
> bonding code later via ptype handlers. This patch converts
> original ptype handlers into "bonding receive probes". These functions
> are called from bond_handle_frame and they are registered per-mode.
> 
> Note that vlan packets are also handled because they are always untagged
> thanks to vlan_untag()
> 
> Note that this also allows arpmon for eth-bond-bridge-vlan topology.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks.
