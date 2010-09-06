From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Using virtio as a physical (wire-level) transport
Date: Mon, 6 Sep 2010 14:19:36 +0300
Message-ID: <20100906111936.GB15608@redhat.com>
References: <20100804230441.GJ23951@ovro.caltech.edu>
 <20100805213050.GA24984@redhat.com>
 <20100805230102.GD4757@ovro.caltech.edu>
 <20100805232042.GA27651@redhat.com>
 <20100806153427.GB12392@ovro.caltech.edu>
 <4C336074-FC8C-4BDF-B945-5295133CDB38@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Zang Roy <r61911@freescale.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Alexander Graf <agraf@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911Ab0IFLZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Sep 2010 07:25:47 -0400
Content-Disposition: inline
In-Reply-To: <4C336074-FC8C-4BDF-B945-5295133CDB38@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 14, 2010 at 07:34:19AM -0400, Alexander Graf wrote:
> I'd vote for defining virtio v2 that makes everything LE. Maybe we
> could even have an LE capability with a grace period of phasing out
> non-LE capable hosts and guests.

So there are multiple ideas floating for modifying the ring,
and together they might warrant virtio2.
This includes removing available ring, publishing consumer indexes,
possibly some interrupt mitigation ideas, and we can put
endian-ness there.

-- 
MST
