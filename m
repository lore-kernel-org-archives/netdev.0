From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: I/OAT: Call for discussion
Date: Wed, 19 Apr 2006 10:12:17 -0700
Message-ID: <20060419101217.0f5d84cf@localhost.localdomain>
References: <5389061B65D50446B1783B97DFDB392D8E9F0A@orsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10700 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751114AbWDSRMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 13:12:20 -0400
To: "Grover, Andrew" <andrew.grover@intel.com>
In-Reply-To: <5389061B65D50446B1783B97DFDB392D8E9F0A@orsmsx411.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Apr 2006 09:39:37 -0700
"Grover, Andrew" <andrew.grover@intel.com> wrote:

> Over the past few months, we (the Intel networking group) have been
> working hard, often off-list, to get the I/OAT patches we've posted here
> merged into the mainline kernel branch, as well as Red Hat and SuSE.
> We've had some success, but not what's really important: getting it into
> the mainline kernel releases.

Vendor kernel support has little or no bearing on eventual inclusion.

> Of course some of this can be blamed on how a corporate culture
> approaches the open source community when it thinks it has something
> that gives it a competitive advantage in the marketplace. If we acted
> like jerks, it's just because we think we have something good here! :) 
> 
> But seriously, I know we've had longer turnaround times in releases and
> replying to comments than people have liked. All we can say is sorry, we
> really have been doing our best. People were kind enough to review our
> patches and suggest over 50 improvements, we have fixed the patches
> accordingly, and we really do appreciate it.
> 
> So OK assume we have a nice pretty patchset. Why should it go in? Since
> we have an NDA with Red Hat we've been trying to convince DaveM and Red
> Hat of I/OAT's merits off-list, but this kind of change needs a more
> public airing of all its pros and cons.

Off list lobbying usually has a negative impact.

> We have posted all the performance data we have gathered so far on the
> linux-net wiki: http://linux-net.osdl.org/index.php/I/OAT , and listed
> the overall concerns that have been expressed in private. I'm hoping you
> will look at the data, re-examine the patches, and then we can talk
> about the technical issues here on the list, getting down to the
> specifics, so we can hash it out in public and settle on the right path
> to take.

The biggest barrier at this point seems to be hardware availability.
People generally don't care unless they use or are going to get that hardware.
Also the big benchmark data, although interesting, is usually only
interesting to vendors.

You probably will have to suffer out of tree for a while until the hardware
becomes more available. When the hardware is more common, then the implementation
details will be sorted out. Also after the 2+ years of getting TSO to work
right, maybe the developers are a little gun shy at this point.
