From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 12 Aug 2012 13:36:42 +0300
Message-ID: <20120812103642.GH1421@redhat.com>
References: <501C3527.6060809@mellanox.com>
 <20120803.143315.151094375569109262.davem@davemloft.net>
 <501C5328.4060301@mellanox.com>
 <20120803.163627.1867181085116225405.davem@davemloft.net>
 <50205DE0.7080706@mellanox.com>
 <87obmnfs4p.fsf@xmission.com>
 <CAJZOPZLApfvgd1wrM2HseNrWh-egaixjhGfB7xBJU1FxFhBdzg@mail.gmail.com>
 <87pq714uaa.fsf@xmission.com>
 <CAJZOPZ+JKZAxF-SaWxCd_8pLqhrLXrPyQHEo0n-gNzuvMOA02w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Ali Ayoub <ali@mellanox.com>,
	David Miller <davem@davemloft.net>, ogerlitz@mellanox.com,
	roland@kernel.org, netdev@vger.kernel.org, sean.hefty@intel.com,
	erezsh@mellanox.co.il, dledford@redhat.com
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828Ab2HLKiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2012 06:38:00 -0400
Content-Disposition: inline
In-Reply-To: <CAJZOPZ+JKZAxF-SaWxCd_8pLqhrLXrPyQHEo0n-gNzuvMOA02w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 09, 2012 at 07:34:23AM +0300, Or Gerlitz wrote:
> > Infiniband is standard enough you could quite easily implement virtual
> > infiniband bridging as an alternative to ethernet bridging.
> 
> Not really, as Michael indicated in his response over this thread
> http://marc.info/?l=linux-netdev&m=134419288218373&w=2
> IPoIB link layer addresses use IB HW constructs for which soft
> hardware address setting isn't supported, and this interferes
> with live migration.
> 
> Or.

But I'd just like to point out your code does not support softmac
either.

-- 
MST
