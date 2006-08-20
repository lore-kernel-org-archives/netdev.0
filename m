From: Solar Designer <solar@openwall.com>
Subject: Re: [PATCH] getsockopt() early argument sanity checking
Date: Sun, 20 Aug 2006 23:45:37 +0400
Message-ID: <20060820194537.GA20849@openwall.com>
References: <20060819230532.GA16442@openwall.com> <200608201034.43588.ak@suse.de> <20060820161602.GA20163@openwall.com> <200608202038.34842.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <wtarreau@hera.kernel.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mother.openwall.net ([195.42.179.200]:46279 "HELO
	mother.openwall.net") by vger.kernel.org with SMTP id S1751194AbWHTUAc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 16:00:32 -0400
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200608202038.34842.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 20, 2006 at 08:38:34PM +0200, Andi Kleen wrote:
> On Sunday 20 August 2006 18:16, Solar Designer wrote:
> > On Sun, Aug 20, 2006 at 10:34:43AM +0200, Andi Kleen wrote:
> > > In general I don't think it makes sense to submit stuff for 2.4 
> > > that isn't in 2.6.
> > 
> > In general I agree, however right now I had the choice between
> > submitting these changes for 2.4 first and not submitting them at all
> > (at least for some months more).  I chose the former.
> 
> If there is really a length checking bug it shouldn't be that hard to fix it 
> in both.

There were such length checking bugs being discovered and fixed in the
past.  In particular, many got fixed between 2.2.18 and 2.2.19; that was
also when I added this hardening measure to -ow patches (starting with
2.2.19-ow1 released 5 years ago).

Of course, any known bugs should be fixed ASAP, but to me that is not a
sufficient reason to not keep a hardening measure like this.  It's just
a matter of opinion.

Alexander
