From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH V2 00/12] Add basic VLAN support to bridges
Date: Wed, 19 Dec 2012 17:04:31 +0000
Message-ID: <20121219170431.GA6975@casper.infradead.org>
References: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
 <20121218223244.GC1690@minipsycho.orion>
 <50D0F23D.4020508@redhat.com>
 <20121219082727.GB1637@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35567 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702Ab2LSREh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 12:04:37 -0500
Content-Disposition: inline
In-Reply-To: <20121219082727.GB1637@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/12 at 09:27am, Jiri Pirko wrote:
> Tue, Dec 18, 2012 at 11:46:21PM CET, vyasevic@redhat.com wrote:
> >On 12/18/2012 05:32 PM, Jiri Pirko wrote:
> >>
> >>
> >>I see that this patchset replicates a lot of code which is already
> >>present in net/8021q/ or include/linux/if_vlan.h. I think it would
> >>be nice to move this code into some "common" place, wouldn't it?
> >>
> >
> >The only replication that I am aware of is in br_vlan_untag().  I
> >thought about pulling that piece out, but I think there is a reason
> >why it's not available when 801q support isn't turned on.  I noted that
> >openvswitch implemented its own vlan header manipulation functions as well.
> 
> openvswitch should use the "common" code as well.

I was just about to mention this. This overlaps with openvswitch
in functionality which I have absoluetely no objections against
but code reuse should come to focus in order to avoid having to
fix bugs twice.
