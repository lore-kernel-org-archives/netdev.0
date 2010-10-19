From: Simon Horman <horms@verge.net.au>
Subject: Re: openvswitch/flow WAS ( Re: [rfc] Merging the Open vSwitch
 datapath
Date: Tue, 19 Oct 2010 16:56:18 +0200
Message-ID: <20101019145618.GF6193@verge.net.au>
References: <20100830062755.GA22396@verge.net.au>
 <87k4n8ow1r.fsf@benpfaff.org>
 <1287142292.3642.19.camel@bigi>
 <AANLkTim2LsFUOVSVss6HqGTxuyGH6eBKQdYabjMoWiaB@mail.gmail.com>
 <1287228959.3664.72.camel@bigi>
 <AANLkTin-zmQdMC_nRvgRr5KdWQvee5xga5sjOfRN2McN@mail.gmail.com>
 <1287404217.3664.182.camel@bigi>
 <20101018152010.GE319@verge.net.au>
 <1287483768.26671.2.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>,
	netdev@vger.kernel.org, ovs-team@nicira.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49024 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486Ab0JSOzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 10:55:48 -0400
Content-Disposition: inline
In-Reply-To: <1287483768.26671.2.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 19, 2010 at 06:22:48AM -0400, jamal wrote:
> On Mon, 2010-10-18 at 17:20 +0200, Simon Horman wrote:
> 
> > As I understand things, the packet goes from the kernel to userspace
> > and then (typically) comes back again.
> 
> Injection back is trivial.
> 
> > I guess that it would be possible to send a copy of the headers
> > to user-sapce while the packet is quarantined in the kernel pending
> > a response from user-space. I say only the headers, as typically
> > that is all user-space needs to make a decision, though I guess it
> > may need the body to make some types of decisions. I have no idea
> > if such a scheme would be desirable in any circumstances.
> 
> quarantine the packet in the kernel would be trickier than sending the
> whole thing up - for a sample of how it is done i believe the netfilter
> approach (ipq?) as well as ipsec would be good samples to look at.

Ok, lets forget my quarantine idea - I was just thinking aloud.

