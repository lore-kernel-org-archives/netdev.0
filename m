From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [E1000-devel] e1000: backport ich9 support from 7.5.5 ?
Date: Tue, 03 Jul 2007 09:13:43 -0400
Message-ID: <468A4B87.1070100@garzik.org>
References: <1183238694.9055.10.camel@blaa> <08FE5CC30C9A3F41BF819A502CF7BF6E019416BA@fmsmsx411.amr.corp.intel.com> <20070703071530.GA25369@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	Mark McLoughlin <markmc@redhat.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jason Lunz <lunz@reflexsecurity.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59844 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754560AbXGCNNx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 09:13:53 -0400
In-Reply-To: <20070703071530.GA25369@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Mon, Jul 02, 2007 at 04:52:52PM -0700, Williams, Mitch A wrote:
>> - We include e1000new in 2.6.23, along side e1000.  We expose ICH9
>>   device IDs in e1000new, and gate the rest of the IDs inside
>>   #ifndef CONFIG_E1000.
> 
> No.  Hardware support in one driver should never be affected by config
> options in another drivers.

Agreed.


> Also I really think there shouldn't be one single driver for all the
> hardware as outlined by intel people in this thread.

Agreed.

(as I've been saying)

	Jeff


