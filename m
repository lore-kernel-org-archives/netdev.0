From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v3 0/6] Big C99 style initializer rework
Date: Tue, 28 Jun 2016 20:07:34 +0200
Message-ID: <20160628180734.GC6733@orbyte.nwl.cc>
References: <d6784d8bb2d84ceab6c1719e32e8fa8e@HQ1WP-EXMB11.corp.brocade.com>
 <20160627105912.7961c3f4@xeon-e3>
 <20160627182302.GB13664@orbyte.nwl.cc>
 <20160627141049.356c1eff@xeon-e3>
 <20160628173723.GA6733@orbyte.nwl.cc>
 <0a003d6f-ae2f-57cb-f3f1-1975011c7b78@cumulusnetworks.com>
 <20160628175835.GB6733@orbyte.nwl.cc>
 <4d5a2616-d5cb-ad3f-e346-a24acc6879aa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:59258 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752305AbcF1SG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 14:06:57 -0400
Content-Disposition: inline
In-Reply-To: <4d5a2616-d5cb-ad3f-e346-a24acc6879aa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2016 at 11:59:04AM -0600, David Ahern wrote:
> On 6/28/16 11:58 AM, Phil Sutter wrote:
> >> since .ifr_qlen is already referenced in that function seems like your
> >> suggestion above (struct ifreq ifr = { .ifr_qlen = 0 };) should be
> >> acceptable.
> >
> > You mean regarding compatibility of using that define? Or are you
> > concerned with gcc creating suboptimal code?
> 
> no, I was thinking in terms of open coding knowledge of a struct.

Still not sure if I understand you correctly. These are not typedefs, so
users are supposed to know the internals and removing a field means
potentially breaking every single user.

> > I'd rather use a more generic approach than the above. Retrospectively,
> > I'd rather have that brace orgy instead of the above since it's
> > intention is more clear and it can be dropped once either gcc guys
> > manage to backport their fix or the last distribution has updated it's
> > compiler.
> 
> ha, that's funny.

At least someone can laugh about it. :)

Cheers, Phil
