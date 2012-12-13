From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Thu, 13 Dec 2012 11:04:04 -0800
Message-ID: <20121213110404.6d662baa@nehalam.linuxnetplumber.net>
References: <CAJZOPZL3grqtd-Tnhr-QxkdFWrhkgcp5+fOUZSaPJd3Ker_7GQ@mail.gmail.com>
	<50C91506.70903@redhat.com>
	<20121213094719.3a7a9408@nehalam.linuxnetplumber.net>
	<20121213.140023.2131448980265576282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, or.gerlitz@gmail.com, netdev@vger.kernel.org,
	mst@redhat.com, john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37967 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932089Ab2LMTFU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 14:05:20 -0500
In-Reply-To: <20121213.140023.2131448980265576282.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Dec 2012 14:00:23 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 13 Dec 2012 09:47:19 -0800
> 
> > On Wed, 12 Dec 2012 18:36:38 -0500
> > Vlad Yasevich <vyasevic@redhat.com> wrote:
> > 
> >> On 12/12/2012 05:54 PM, Or Gerlitz wrote:
> >> > On Wed, Dec 12, 2012 at 10:01 PM, Vlad Yasevich <vyasevic@redhat.com> wrote:  
> >> >> This series of patches provides an ability to add VLANs to the bridge
> >> >> 
> > 
> > The bigger question is why is this impossible or too awkward with existing
> > netfilter (ebtables) functionality? As a practical matter, I like to keep
> > the bridging code as simple as possible and move the complexity away from
> > the core.
> > 
> > Also, if the functionality lived in netfilter rules, the developer and user
> > would have a more freedom to implement complex rulesets.
> 
> I do not consider it wise to create more, rather then fewer, users
> of ebtables.
> 
> It is one of the most poorly constructed subsystems in the entire
> networking.

Maybe a better filtering architecture (at the bridge level) would
be a good project.
