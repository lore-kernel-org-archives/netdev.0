From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: No iproute2 for 2.6.38
Date: Thu, 17 Mar 2011 11:14:55 -0300
Message-ID: <20110317141455.GE1724@khazad-dum.debian.net>
References: <20110315195534.0cc43032@nehalam>
 <4D804EBD.4030904@us.ibm.com>
 <20110316170441.351efba7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5.smtp.messagingengine.com ([66.111.4.29]:60171 "EHLO
	out5.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752001Ab1CQOO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 10:14:59 -0400
Content-Disposition: inline
In-Reply-To: <20110316170441.351efba7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Mar 2011, Stephen Hemminger wrote:
> > 2.6.38 includes support for macvlan/macvtap 'passthru' mode that allows 
> > assigning
> > SR-IOV VFs to a KVM guest via macvtap/virtio.
> > It is not possible to support live migration using direct assignment of 
> > VF's to a guest,
> > but 'passthu' assignment makes this possible.
> > 
> > Enabling this feature requires the following patch to iproute2 that 
> > allows creating macvlan
> > device in 'passthru' mode.
> >      http://patchwork.ozlabs.org/patch/69515/
> > Looks like this patch is still marked as 'Awaiting upstream'.
> > 
> > Could you apply this patch and it would be great if a version of 
> > iproute2 is released for 2.6.38.
> 
> Sorry missed it applied to repository, still not sure worth a new release.

Release early, release often.  And someone actually bothered asking you to
specifically, so it clearly is going to be useful to that someone.

So, why not do a 2.6.38 release?

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
