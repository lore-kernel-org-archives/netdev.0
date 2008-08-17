From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sun, 17 Aug 2008 12:02:13 +0300
Message-ID: <200808171202.13422.denys@visp.net.lb>
References: <20080815190905.M56388@visp.net.lb> <200808162222.56318.denys@visp.net.lb> <20080816193956.GB24083@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:58472 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbYHQJDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 05:03:22 -0400
In-Reply-To: <20080816193956.GB24083@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is it was a fix? Because for now it is running fine from night (but i have 
enabled some minor debug options in kernel). No crash or warning yet.

I disable now debug as it was before and testing more.

On Saturday 16 August 2008, Jarek Poplawski wrote:
> > >  	spin_lock_init(&dev_queue->_xmit_lock);
> > > +	spin_lock_init(&dev_queue->qdisc_lock);
> > >  	netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
> > >  	dev_queue->xmit_lock_owner = -1;
> > >  }
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


