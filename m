From: Faisal Latif <faisal.latif@intel.com>
Subject: Re: [PATCH V1 08/16] i40iw: add files for iwarp interface
Date: Thu, 24 Dec 2015 01:31:37 -0600
Message-ID: <20151224073137.GB35696@flatif-MOBL1>
References: <1450739596-23276-1-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-2-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-3-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-4-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-5-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-6-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-7-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-8-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-9-git-send-email-faisal.latif@intel.com>
 <567ACED9.2040701@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dledford@redhat.com" <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"e1000-rdma@lists.sourceforge.net" <e1000-rdma@lists.sourceforge.net>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28309 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933076AbbLXHbv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Dec 2015 02:31:51 -0500
Content-Disposition: inline
In-Reply-To: <567ACED9.2040701@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 23, 2015 at 08:42:01AM -0800, Or Gerlitz wrote:
> On 12/22/2015 1:13 AM, Faisal Latif wrote:
> > +
> > +enum i40iw_memreg_type {
> > +	IW_MEMREG_TYPE_MEM = 0x0000,
> > +	IW_MEMREG_TYPE_QP = 0x0001,
> > +	IW_MEMREG_TYPE_CQ = 0x0002,
> > +	IW_MEMREG_TYPE_MW = 0x0003,
> > +	IW_MEMREG_TYPE_FMR = 0x0004,
> > +	IW_MEMREG_TYPE_FMEM = 0x0005,
> > +};
> 
> Can't you re-use IB core values or derive that from the actual uverbs 
> command?
I did not see anything which will have types that I needed. It will be confusing
otherwise.  I will be reducing number of types from here though.
> 
> Or.

Thanks
Faisal
