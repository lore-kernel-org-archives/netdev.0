From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Fix sysctl warnings about missing strategy
Date: Wed, 14 Nov 2007 17:14:36 -0800
Message-ID: <20071115011431.GA8325@verge.net.au>
References: <200711131129.58868.borntraeger@de.ibm.com> <20071113.024500.155458534.davem@davemloft.net> <20071114021131.GB2523@verge.net.au> <Pine.LNX.4.58.0711150225280.3658@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, borntraeger@de.ibm.com,
	netdev@vger.kernel.org, ebiederm@xmission.com, wensong@linux-vs.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:37114 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757518AbXKOBOn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 20:14:43 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0711150225280.3658@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 15, 2007 at 02:38:32AM +0200, Julian Anastasov wrote:

Hi Julian,

> On Tue, 13 Nov 2007, Simon Horman wrote:

[snip]

> > As for the commented out entries. They are supposed to be exposed by
> > some other means - I believe the thinking was to comply with the don't
> > expose stuff in proc any more idea. Where is the best place to expose
> > this kind of stuff?
> 
> 	I assume /proc/sys is still valid place, only sysctl interface
> is scheduled for removal.

I'm happy to add them there, so long as that is a good place.

> So, as long as these entries are not
> accessible from sysctl it is safe to run without strategy handler but if
> values can be changed then we will need strategy handler to
> properly call update_defense_level() as done in proc_do_defense_mode()
> as proc_handler. There could be side effects if new mode is not applied.

I'm not sure what you are getting at there. I did write a stratergy
for update_defense_level(), but I didn't post it, as I thought that
it would not be needed if CTL_UNNUMBERED is used.

-- 
Horms, California Edition

