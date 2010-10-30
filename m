From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] macvlan: Introduce 'passthru' mode to takeover the
 underlying device
Date: Sat, 30 Oct 2010 18:57:50 +0200
Message-ID: <20101030165750.GB17210@redhat.com>
References: <1288307450.30131.82.camel@sridhar.beaverton.ibm.com>
 <201010291545.17910.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45570 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754632Ab0J3Q6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Oct 2010 12:58:05 -0400
Content-Disposition: inline
In-Reply-To: <201010291545.17910.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 29, 2010 at 03:45:17PM +0200, Arnd Bergmann wrote:
> On Friday 29 October 2010, Sridhar Samudrala wrote:
> > With the current default 'vepa' mode, a KVM guest using virtio with 
> > macvtap backend has the following limitations.
> > - cannot change/add a mac address on the guest virtio-net
> 
> I believe this could be changed if there is a neeed, but I actually
> consider it one of the design points of macvlan that the guest
> is not able to change the mac address. With 802.1Qbg you rely on
> the switch being able to identify the guest by its MAC address,
> which the host kernel must ensure.
> 
> > - cannot create a vlan device on the guest virtio-net
> 
> Why not? If this doesn't work, it's probably a bug!
> Why does the passthru mode enable it if it doesn't work
> already?
> 
> > - cannot enable promiscuous mode on guest virtio-net
> 
> Could you elaborate why such a setup would be useful?
> 
> 	Arnd

E.g. to support bridging in the guest.

-- 
MST
