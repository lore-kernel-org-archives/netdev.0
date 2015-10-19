From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] openvswitch: Scrub skb between namespaces
Date: Sun, 18 Oct 2015 22:25:17 -0700 (PDT)
Message-ID: <20151018.222517.734844235920874923.davem@davemloft.net>
References: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, tgraf@suug.ch,
	hannes@redhat.com, jesse@nicira.com
To: joestringer@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654AbbJSFI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 01:08:59 -0400
In-Reply-To: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>
Date: Fri, 16 Oct 2015 11:08:18 -0700

> If OVS receives a packet from another namespace, then the packet should
> be scrubbed. However, people have already begun to rely on the behaviour
> that skb->mark is preserved across namespaces, so retain this one field.
> 
> This is mainly to address information leakage between namespaces when
> using OVS internal ports, but by placing it in ovs_vport_receive() it is
> more generally applicable, meaning it should not be overlooked if other
> port types are allowed to be moved into namespaces in future.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Applied, thanks.
