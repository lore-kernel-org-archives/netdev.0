From: jamal <hadi@cyberus.ca>
Subject: Re: openvswitch/flow WAS ( Re: [rfc] Merging the Open vSwitch
 datapath
Date: Tue, 19 Oct 2010 06:22:48 -0400
Message-ID: <1287483768.26671.2.camel@bigi>
References: <20100830062755.GA22396@verge.net.au>
	 <87k4n8ow1r.fsf@benpfaff.org> <1287142292.3642.19.camel@bigi>
	 <AANLkTim2LsFUOVSVss6HqGTxuyGH6eBKQdYabjMoWiaB@mail.gmail.com>
	 <1287228959.3664.72.camel@bigi>
	 <AANLkTin-zmQdMC_nRvgRr5KdWQvee5xga5sjOfRN2McN@mail.gmail.com>
	 <1287404217.3664.182.camel@bigi>  <20101018152010.GE319@verge.net.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>,
	netdev@vger.kernel.org, ovs-team@nicira.com
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:44112 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337Ab0JSKWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 06:22:52 -0400
Received: by gxk21 with SMTP id 21so603665gxk.19
        for <netdev@vger.kernel.org>; Tue, 19 Oct 2010 03:22:52 -0700 (PDT)
In-Reply-To: <20101018152010.GE319@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-10-18 at 17:20 +0200, Simon Horman wrote:

> As I understand things, the packet goes from the kernel to userspace
> and then (typically) comes back again.

Injection back is trivial.

> I guess that it would be possible to send a copy of the headers
> to user-sapce while the packet is quarantined in the kernel pending
> a response from user-space. I say only the headers, as typically
> that is all user-space needs to make a decision, though I guess it
> may need the body to make some types of decisions. I have no idea
> if such a scheme would be desirable in any circumstances.

quarantine the packet in the kernel would be trickier than sending the
whole thing up - for a sample of how it is done i believe the netfilter
approach (ipq?) as well as ipsec would be good samples to look at.

cheers,
jamal

