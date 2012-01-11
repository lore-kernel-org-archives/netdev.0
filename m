From: Andy Gospodarek <gospo@redhat.com>
Subject: Re: [PATCHv2] bond_alb: don't disable softirq under bond_alb_xmit
Date: Wed, 11 Jan 2012 16:26:36 -0500
Message-ID: <20120111212636.GE32485@quad.redhat.com>
References: <1326146497-27711-1-git-send-email-maxim.uvarov@oracle.com>
 <20120111.125246.979686086126749318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: maxim.uvarov@oracle.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, amwang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29361 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932749Ab2AKV1A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 16:27:00 -0500
Content-Disposition: inline
In-Reply-To: <20120111.125246.979686086126749318.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 12:52:46PM -0800, David Miller wrote:
> From: Maxim Uvarov <maxim.uvarov@oracle.com>
> Date: Mon,  9 Jan 2012 14:01:37 -0800
> 
> > No need to lock soft irqs under bond_alb_xmit()
> > which already has softirq disabled.
> > 
> > Changes:
> > 1. add non-bh/bh version to tlb_clear_slave()
> > 
> > 2. represent BH and non BH hash table locks
> > _lock_rx_hashtbl_bh/_unlock_rx_hashtbl_bh
> > _lock_rx_hashtbl/_unlock_rx_hashtbl
> > _lock_tx_hashtbl_bh/_unlock_tx_hashtbl_bh
> > _lock_tx_hashtbl/_unlock_tx_hashtbl
> > 
> > Signed-off-by: Maxim Uvarov <maxim.uvarov@oracle.com>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> Applied, thanks.

Thanks, Dave.  I'm still testing, but everything looks good so far.  I
ran into an issue with my test system and it took longer to get going
than I expected.  I should be done later tonight and will post if I find
anything wrong.

It's probably too late, but you can feel free to add a

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

if you want.
