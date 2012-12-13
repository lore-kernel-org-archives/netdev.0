From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Thu, 13 Dec 2012 14:02:18 -0800
Message-ID: <20121213140218.2c705bb5@nehalam.linuxnetplumber.net>
References: <CAJZOPZL3grqtd-Tnhr-QxkdFWrhkgcp5+fOUZSaPJd3Ker_7GQ@mail.gmail.com>
	<50C91506.70903@redhat.com>
	<20121213094719.3a7a9408@nehalam.linuxnetplumber.net>
	<20121213.140023.2131448980265576282.davem@davemloft.net>
	<20121213110404.6d662baa@nehalam.linuxnetplumber.net>
	<50CA37DA.1090905@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vyasevic@redhat.com,
	or.gerlitz@gmail.com, netdev@vger.kernel.org, mst@redhat.com,
	john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54157 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756625Ab2LMWDd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 17:03:33 -0500
In-Reply-To: <50CA37DA.1090905@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Dec 2012 15:17:30 -0500
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 12-12-13 02:04 PM, Stephen Hemminger wrote:
> >
> > Maybe a better filtering architecture (at the bridge level) would
> > be a good project.
> >
> 
> Ok, please before you go off and re-invent the winter tire - take a look 
> at tc filtering which works well with any netdev and point out what the 
> issues are.
> 
> 
> cheers,
> jamal

Nah, no reinvention, people who want to do filtering and bridging
just use openvswitch instead.
