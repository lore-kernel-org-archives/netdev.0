From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Mon, 12 Jun 2006 11:24:39 -0400
Message-ID: <20060612152434.GA14851@tuxdriver.com>
References: <20060610175010.GA4617@divinity> <20060610180850.GP7420@redhat.com> <20060611222719.GA13139@redhat.com> <20060611224054.GB13139@redhat.com> <20060611224954.GA2880@divinity>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	proski@gnu.org, hermes@gibson.dropbear.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-70-61-120-52.midsouth.biz.rr.com ([70.61.120.52]:32524
	"EHLO ra.tuxdriver.com") by vger.kernel.org with ESMTP
	id S1752037AbWFLPZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 11:25:11 -0400
To: Faidon Liambotis <faidon@cube.gr>
Content-Disposition: inline
In-Reply-To: <20060611224954.GA2880@divinity>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2006 at 01:49:54AM +0300, Faidon Liambotis wrote:

> Having two drivers supporting the same set of hardware seems pretty
> pointless to me. Plus, it confuses hotplugging/automatic detection.

This subject comes-up from time to time.  In fact, I'm pretty sure
it came-up very recently w.r.t. orinoco and hostap.

The consensus seems to be that drivers should have IDs for all devices
they support, even if that means that some devices are supported by
multiple drivers.  This leaves the choice of which driver to use in
the hands of the user and/or distro.

If the Orinoco guys want this patch, I'll consider it.  Otherwise,
I'm not inclined to take it.

John
-- 
John W. Linville
linville@tuxdriver.com
