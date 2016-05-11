From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Wed, 11 May 2016 15:57:26 +0200
Message-ID: <20160511155726.17268c07@griffin>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
	<1462347393-22354-5-git-send-email-simon.horman@netronome.com>
	<CAOrHB_AMC4x=NnLTpGbXdW31Vp0f1R3VoaD9ksST5EesrdGsug@mail.gmail.com>
	<20160506055705.GA9276@penelope.isobedori.kobe.vergenet.net>
	<20160506112514.47f6e9dc@griffin>
	<20160509080420.GA4470@vergenet.net>
	<20160510140106.367936fb@griffin>
	<20160511015009.GB24436@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58645 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932725AbcEKN5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2016 09:57:31 -0400
In-Reply-To: <20160511015009.GB24436@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 May 2016 10:50:12 +0900, Simon Horman wrote:
> On Tue, May 10, 2016 at 02:01:06PM +0200, Jiri Benc wrote:
> > We have two options here:
> > 
> > 1. As for metadata tunnels all the info is in metadata_dst and we
> >    don't need the IP/GRE header for anything, we can make the ipgre
> >    interface ARPHRD_NONE in metadata based mode.
> > 
> > 2. We can fix this up in ovs after receiving the packet from
> >    ARPHRD_IPGRE interface.
> > 
> > I think the first option is the correct one. We already don't assign
> > dev->header_ops in metadata mode. I'll prepare a patch.
> 
> I agree that 1. seems to be the better approach.

I just sent a patch that fixes this. And we have the same bug in
VXLAN-GPE, I sent a patch, too.

> Sure, if that is your preference I think it should be simple enough to
> implement. I agree that netdev_port_receive() looks like a good place for
> this.

Great, thanks!

 Jiri
