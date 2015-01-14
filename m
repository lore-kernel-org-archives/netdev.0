From: "Zhou, Danny" <danny.zhou@intel.com>
Subject: RE: [RFC PATCH v2 1/2] net: af_packet support for direct ring
 access in user space
Date: Wed, 14 Jan 2015 15:28:50 +0000
Message-ID: <DFDF335405C17848924A094BC35766CF0AA36561@SHSMSX104.ccr.corp.intel.com>
References: <54B51BEC.2040809@redhat.com>	<54B538C1.6000500@gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAC6BA5@AcuExch.aculab.com>
 <20150113.122733.1459000731112321026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"brouer@redhat.com" <brouer@redhat.com>
To: David Miller <davem@davemloft.net>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:53157 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343AbbANP3A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 10:29:00 -0500
In-Reply-To: <20150113.122733.1459000731112321026.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, January 14, 2015 1:28 AM
> To: David.Laight@ACULAB.COM
> Cc: john.fastabend@gmail.com; dborkman@redhat.com; hannes@stressinduktion.org; netdev@vger.kernel.org; Zhou, Danny;
> nhorman@tuxdriver.com; Ronciak, John; brouer@redhat.com
> Subject: Re: [RFC PATCH v2 1/2] net: af_packet support for direct ring access in user space
> 
> From: David Laight <David.Laight@ACULAB.COM>
> Date: Tue, 13 Jan 2015 17:15:30 +0000
> 
> > How about something like:
> >
> > struct tpacket_dma_mem_region {
> >     __u64 addr;        /* userspace virtual address */
> >     __u64 phys_addr;    /* physical address */
> >     __u64 iova;        /* IO virtual address used for DMA */
> >     __u64 size;    /* size of region */
> >     int direction;        /* dma data direction */
> > } aligned(8);
> >
> > So that it is independant of 32/64 bits.
> > It is a shame that gcc has no way of defining a 64bit 'void *' on 32bit systems.
> > You can use a union, but you still need to zero extend the value on LE (worse on BE).
> 
> We have an __aligned_u64, please use that.

Thanks, will do.
