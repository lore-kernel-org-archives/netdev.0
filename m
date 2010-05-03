From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 PATCH 2/2] add ndo_set_port_profile op support for enic dynamic vnics
Date: Mon, 3 May 2010 13:32:34 +0200
Message-ID: <201005031332.34955.arnd@arndb.de>
References: <C7FEE68A.2CBEF%scofeldm@cisco.com> <201004291748.38702.arnd@arndb.de> <alpine.LFD.2.00.1005022119140.16925@vk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, chrisw@redhat.com,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>
To: Vivek Kashyap <kashyapv@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:61298 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757831Ab0ECLcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 07:32:41 -0400
In-Reply-To: <alpine.LFD.2.00.1005022119140.16925@vk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 03 May 2010, Vivek Kashyap wrote:
> > After a successful pre-associate-with-resource-reservation step, we
> > know that the actual associate step will be both fast and successful.
> > After it completes, the VSI is known to be on the destination
> > and all traffic goes there (replacing the gratuitous ARP method we do
> > today).
> >
> > I don't think we'd ever do a pre-associate without the
> > resource-reservation, but the standard defines both. In theory,
> > we could do a pre-associate at every switch in the data center
> > in order to find out if it's possible to migrate there.
> >
> > If you want to have more details, please look at the draft spec at
> > http://www.ieee802.org/1/files/public/docs2010/bg-joint-evb-0410v1.pdf
> 
> The basic difference is that in 'pre-associate with resoruce reservation', the 
> local buffers and resources needed for the eventual 'associate' are reserved
> at the switch port.  Therefore the associate will not fail with 
> 'insufficient resources'. It might otherwise.

Yes, that's exactly what I wrote. So do you have any idea why we would
ever not want to do the resource reservation?

	Arnd
