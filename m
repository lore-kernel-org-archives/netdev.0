From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 11/14] vlan: clean up vlan_dev_hard_start_xmit()
Date: Fri, 10 Aug 2012 15:47:51 +0800
Message-ID: <1344584871.29601.0.camel@cr0>
References: <1344582637-18261-1-git-send-email-amwang@redhat.com>
	 <1344582637-18261-12-git-send-email-amwang@redhat.com>
	 <Pine.GSO.4.63.1208100913090.13591@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755942Ab2HJHsB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 03:48:01 -0400
In-Reply-To: <Pine.GSO.4.63.1208100913090.13591@stinky-local.trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-10 at 09:14 +0200, Patrick McHardy wrote:
> On Fri, 10 Aug 2012, Cong Wang wrote:
> > static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
> > 					    struct net_device *dev)
> > {
> > +	struct vlan_dev_priv *info = vlan_dev_priv(dev);
> 
> We're consistently using "vlan" for the private data throughout
> the code. Please keep it that way.
> 

Ok, I will update it.

Thanks!
