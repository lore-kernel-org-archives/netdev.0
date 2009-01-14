From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 1/4] virtio_net: Allow setting the MAC address of the
 NIC
Date: Wed, 14 Jan 2009 08:40:12 -0700
Message-ID: <1231947612.7109.267.camel@lappy>
References: <1231881796.9095.186.camel@bling>
	 <1231928106.4944.289.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:38787 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759552AbZANPkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 10:40:11 -0500
In-Reply-To: <1231928106.4944.289.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 10:15 +0000, Mark McLoughlin wrote:
> On Tue, 2009-01-13 at 14:23 -0700, Alex Williamson wrote:
> 
> Commit log explaining why we need this.

Sorry, my commit logs are pretty weak across the board.  I'll update
them all.

> > +	} else {
> >  		random_ether_addr(dev->dev_addr);
> > +		vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
> > +				  dev->dev_addr, dev->addr_len);
> > +	}
> 
> Please make sure you test this with a host which doesn't set a default
> mac address, otherwise it's "untested buggy code" :-)

Good idea, I'll hack the backend to not advertise that feature and make
sure this code gets exercised a least once.  Thanks,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

