From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 7/7] ip/tcp_metrics: Simplify process_msg a bit
Date: Wed, 22 Jun 2016 14:55:57 +0200
Message-ID: <20160622125557.GB15980@orbyte.nwl.cc>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc>
 <1466525921-15738-8-git-send-email-phil@nwl.cc>
 <87k2hhmp8q.fsf@frog.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
To: Jakub Sitnicki <jkbs@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58738 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752182AbcFVMz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 08:55:59 -0400
Content-Disposition: inline
In-Reply-To: <87k2hhmp8q.fsf@frog.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 01:34:13PM +0200, Jakub Sitnicki wrote:
> On Tue, Jun 21, 2016 at 06:18 PM CEST, Phil Sutter <phil@nwl.cc> wrote:
[...]
> > -	a = attrs[TCP_METRICS_ATTR_ADDR_IPV4];
> > -	if (a) {
> > +	if ((a = attrs[TCP_METRICS_ATTR_ADDR_IPV4])) {
> 
> Copy the pointer inside the branch?
> 
> Same gain on indentation while keeping checkpatch happy.

Good point! Thanks for the patch. :)

Cheers, Phil
