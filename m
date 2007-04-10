From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 2/2] NET: Multiqueue network device support implementation.
Date: Tue, 10 Apr 2007 19:54:54 +0400
Message-ID: <20070410155454.GA1949@2ka.mipt.ru>
References: <20070410082049.GC16621@2ka.mipt.ru> <D5C1322C3E673F459512FB59E0DDC329029E448D@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58166 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031002AbXDJQK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 12:10:57 -0400
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329029E448D@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2007 at 08:41:49AM -0700, Waskiewicz Jr, Peter P (peter.p.waskiewicz.jr@intel.com) wrote:
> > On Mon, Apr 09, 2007 at 02:28:41PM -0700, Peter P Waskiewicz 
> > Jr (peter.p.waskiewicz.jr@intel.com) wrote:
> > > + 	alloc_size = (sizeof(struct net_device_subqueue) * queue_count);
> > > + 
> > > + 	p = kzalloc(alloc_size, GFP_KERNEL);
> > > + 	if (!p) {
> > > + 		printk(KERN_ERR "alloc_netdev: Unable to 
> > allocate queues.\n");
> > > + 		return NULL;
> > 
> > I think you either do not want to print it, or want 
> > additional details about device...
> 
> Ok.  This is essentially the same output printed if the netdev itself
> cannot be allocated.  Should I update both strings to have more
> device-specific information?

I wonder, if it is ever possible with gfp_kernel...

I think different patch would be ok.

-- 
	Evgeniy Polyakov
