From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Fri, 12 Oct 2007 09:08:58 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5203887DD1@orsmsx418.amr.corp.intel.com>
References: <20071010003716.GB552@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hadi@cyberus.ca>, <shemminger@linux-foundation.org>,
	<jeff@garzik.org>, <johnpol@2ka.mipt.ru>,
	<herbert@gondor.apana.org.au>, <gaagaan@gmail.com>,
	<Robert.Olsson@data.slu.se>, <netdev@vger.kernel.org>,
	<rdreier@cisco.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	<mcarlson@broadcom.com>, <jagana@us.ibm.com>,
	<general@lists.openfabrics.org>, <mchan@broadcom.com>,
	<tgraf@suug.ch>, <randy.dunlap@oracle.com>, <sri@us.ibm.com>,
	<kaber@trash.net>
To: "Andi Kleen" <andi@firstfloor.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3703 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760566AbXJLQJD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 12:09:03 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20071010003716.GB552@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>> When the hw TX queue gains space, the driver self-batches packets
>> from the sw queue to the hw queue.
> 
> I don't really see the advantage over the qdisc in that scheme.
> It's certainly not simpler and probably more code and would likely
> also not require less locks (e.g. a currently lockless driver
> would need a new lock for its sw queue). Also it is unclear to me
> it would be really any faster.

related to this comment, does Linux have a lockless (using atomics)
singly linked list element?  That would be very useful in a driver hot
path.
