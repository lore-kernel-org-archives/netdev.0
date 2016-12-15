From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC v2 03/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) netdev
Date: Thu, 15 Dec 2016 09:26:47 -0800
Message-ID: <20161215172647.GA18991@infradead.org>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1481788782-89964-4-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215170109.GC3264@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373AB0C9556@ORSMSX109.amr.corp.intel.com>
 <20161215172437.GA11387@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Hefty, Sean" <sean.hefty@intel.com>,
        "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
        "Weiny, Ira" <ira.weiny@intel.com>,
        "Warrier, Sadanand" <sadanand.warrier@intel.com>,
        "Dutt, Sudeep" <sudeep.dutt@intel.com>,
        "Jajodia, Tanya K" <tanya.k.jajodia@intel.com>,
        "Kacprowski, Andrzej" <Andrzej.Kacprowski@intel.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45442 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757299AbcLOR1B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 12:27:01 -0500
Content-Disposition: inline
In-Reply-To: <20161215172437.GA11387@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2016 at 10:24:37AM -0700, Jason Gunthorpe wrote:
> Do not use bitfields without providing a BE version of the bitfield.

Do not use bitfields ever for protocol defintions, period.
