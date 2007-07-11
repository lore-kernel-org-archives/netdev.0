From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] IPv6: optionaly validate RAs on raw sockets
Date: Wed, 11 Jul 2007 17:17:13 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0707111715510.26078@d.namei>
References: <OF12E7973A.D9D0F9C5-ON88257315.005882D0-88257315.0058D5B9@us.ibm.com>
 <200707111919.11746@auguste.remlab.net> <20070711.135646.115909857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rdenis@simphalempin.com, dlstevens@us.ibm.com,
	vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:59001 "EHLO
	mail1.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbXGKVRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 17:17:17 -0400
In-Reply-To: <20070711.135646.115909857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Jul 2007, David Miller wrote:

> > One remaining corner case is NFS/IPv6 root, whereby userland won't have 
> > a chance to start before the network, and hence may miss the solicited 
> > RA. Or would it? By default, the next unsolicited RA can be anytime 
> > from now to after 10 minutes, so that's not sufficient. I wouldn't 
> > personnaly care, but...
> 
> We already have cases like that with network device firmware that
> has to be loaded in from the filesystem in userspace, and the
> answer is to use a properly populated initrd.
> 
> Same goes for things like this.
> 
> That's the fact of life these days, like it or not.

Same story for NFS root when using strong authentication -- something has 
to be running in userland to manage that.



- James
-- 
James Morris
<jmorris@namei.org>
