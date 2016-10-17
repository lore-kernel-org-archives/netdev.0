From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net] flow_dissector: Check skb for VLAN only if skb
 specified.
Date: Mon, 17 Oct 2016 16:27:27 -0400
Message-ID: <20161017202727.GQ25403@egarver>
References: <1476735717-20802-1-git-send-email-e@erig.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hadar Hen Zion <hadarh@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42272 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758959AbcJQU13 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 16:27:29 -0400
Content-Disposition: inline
In-Reply-To: <1476735717-20802-1-git-send-email-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 04:21:57PM -0400, Eric Garver wrote:
> From: Eric Garver <egarver@redhat.com>
> 
> Fixes a panic when calling eth_get_headlen(). Noticed on i40e driver.
> 
> Fixes: d5709f7ab776 ("flow_dissector: For stripped vlan, get vlan info from skb->vlan_tci")
> Signed-off-by: Eric Garver <e@erig.me>

Oops. Messed the From. Sending a v2.
