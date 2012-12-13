From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Thu, 13 Dec 2012 09:47:19 -0800
Message-ID: <20121213094719.3a7a9408@nehalam.linuxnetplumber.net>
References: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
	<CAJZOPZL3grqtd-Tnhr-QxkdFWrhkgcp5+fOUZSaPJd3Ker_7GQ@mail.gmail.com>
	<50C91506.70903@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, mst@redhat.com, john.r.fastabend@intel.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59095 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754438Ab2LMRse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 12:48:34 -0500
In-Reply-To: <50C91506.70903@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 18:36:38 -0500
Vlad Yasevich <vyasevic@redhat.com> wrote:

> On 12/12/2012 05:54 PM, Or Gerlitz wrote:
> > On Wed, Dec 12, 2012 at 10:01 PM, Vlad Yasevich <vyasevic@redhat.com> wrote:  
> >> This series of patches provides an ability to add VLANs to the bridge
> >> 

The bigger question is why is this impossible or too awkward with existing
netfilter (ebtables) functionality? As a practical matter, I like to keep
the bridging code as simple as possible and move the complexity away from
the core.

Also, if the functionality lived in netfilter rules, the developer and user
would have a more freedom to implement complex rulesets.
