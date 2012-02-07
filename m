From: Marek Vasut <marek.vasut@gmail.com>
Subject: Re: [PATCH RESEND] FEC: Rename dev to ndev, fix compile error
Date: Wed, 8 Feb 2012 00:37:37 +0100
Message-ID: <201202080037.37681.marek.vasut@gmail.com>
References: <1328654643-28442-1-git-send-email-marek.vasut@gmail.com> <CAOMZO5Dq4o9BWfsL97awSaxeqHrLZK5GYb+JS1cpghSeaEfYYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Pradeep A Dalvi <netdev@pradeepdalvi.com>,
	"David S. Miller" <davem@davemloft.net>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:53961 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755998Ab2BGXhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 18:37:40 -0500
Received: by eekc14 with SMTP id c14so2715887eek.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 15:37:39 -0800 (PST)
In-Reply-To: <CAOMZO5Dq4o9BWfsL97awSaxeqHrLZK5GYb+JS1cpghSeaEfYYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Marek,
> 
> On Tue, Feb 7, 2012 at 8:44 PM, Marek Vasut <marek.vasut@gmail.com> wrote:
> > The following commit introduced a typo, this commit fixes it.
> > 
> > commit 21a4e46995fa1a76281ac0281ff837f706231a37
> > Author: Pradeep A Dalvi <netdev@pradeepdalvi.com>
> > Date:   Sun Feb 5 02:50:10 2012 +0000
> > 
> >    netdev: ethernet dev_alloc_skb to netdev_alloc_skb
> > 
> >    Replaced deprecating dev_alloc_skb with netdev_alloc_skb in
> > drivers/net/ethernet - Removed extra skb->dev = dev after
> > netdev_alloc_skb
> > 
> > Signed-off-by: Marek Vasut <marek.vasut@gmail.com>
> > Cc: Pradeep A Dalvi <netdev@pradeepdalvi.com>
> > Cc: David S. Miller <davem@davemloft.net>
> 
> I have already sent a fix for this issue and David has applied it.
> 
> Regards,
> 
> Fabio Estevam

It wasn't in next ... all right, drop this patch.

M
