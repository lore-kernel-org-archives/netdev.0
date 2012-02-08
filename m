From: Marek Vasut <marek.vasut@gmail.com>
Subject: Re: [PATCH] FEC: Rename dev to ndev, fix compile error
Date: Wed, 8 Feb 2012 01:09:24 +0100
Message-ID: <201202080109.24840.marek.vasut@gmail.com>
References: <1328654548-28396-1-git-send-email-marek.vasut@gmail.com> <20120207.190430.1219273346186860486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infreadead.org, netdev@vger.kernel.org,
	netdev@pradeepdalvi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40856 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080Ab2BHAJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 19:09:27 -0500
Received: by eekc14 with SMTP id c14so2721305eek.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 16:09:26 -0800 (PST)
In-Reply-To: <20120207.190430.1219273346186860486.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Marek Vasut <marek.vasut@gmail.com>
> Date: Tue,  7 Feb 2012 23:42:28 +0100
> 
> > The following commit introduced a typo, this commit fixes it.
> > 
> > commit 21a4e46995fa1a76281ac0281ff837f706231a37
> > Author: Pradeep A Dalvi <netdev@pradeepdalvi.com>
> > Date:   Sun Feb 5 02:50:10 2012 +0000
> > 
> >     netdev: ethernet dev_alloc_skb to netdev_alloc_skb
> >     
> >     Replaced deprecating dev_alloc_skb with netdev_alloc_skb in
> >     drivers/net/ethernet
> >     
> >       - Removed extra skb->dev = dev after netdev_alloc_skb
> > 
> > Signed-off-by: Marek Vasut <marek.vasut@gmail.com>
> 
> This is already fixed in the net-next tree.

Right, it wasn't in -next so I sent it. Thanks

M
