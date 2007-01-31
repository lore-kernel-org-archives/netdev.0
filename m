From: Andi Kleen <ak@suse.de>
Subject: Re: [linux-pm] [RFC] Runtime power management =?iso-8859-1?q?on=09ipw2100?=
Date: Wed, 31 Jan 2007 11:48:20 +0100
Message-ID: <200701311148.20777.ak@suse.de>
References: <20070131075249.GA22115@srcf.ucam.org> <p731wlbphz3.fsf@bingen.suse.de> <20070131102744.GA24424@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Amit Kucheria <amit.kucheria@nokia.com>,
	ipw2100-devel@lists.sourceforge.net, linux-pm@lists.osdl.org,
	netdev@vger.kernel.org
To: Matthew Garrett <mjg59@srcf.ucam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:52685 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932995AbXAaKs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 05:48:29 -0500
In-Reply-To: <20070131102744.GA24424@srcf.ucam.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 31 January 2007 11:27, Matthew Garrett wrote:
> On Wed, Jan 31, 2007 at 12:13:04PM +0100, Andi Kleen wrote:
> > Matthew Garrett <mjg59@srcf.ucam.org> writes:
> > > 
> > > PCI seems to require a delay of 10ms when sequencing from D3 to D0, 
> > > which probably isn't acceptable latency for an "up" state.
> > 
> > It might be if the interface has been idle for some time
> > (and the delay is not busy looping of course)
> 
> Hm. How would this interact with receiving packets?

The hardware will hopefully have support to wake itself up when that 
happens.

-Andi
