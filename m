From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 7/8] openvswitch: Drop user features if old user
 space attempted to create datapath
Date: Thu, 21 Nov 2013 22:20:47 +0000
Message-ID: <20131121222047.GA14252@casper.infradead.org>
References: <cover.1385057355.git.tgraf@suug.ch>
 <68ddfb6e0ef4401f246f2599ade5c15b25063736.1385057355.git.tgraf@suug.ch>
 <1385058197.1586.15.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse@nicira.com, davem@davemloft.net, dev@openvswitch.org,
	netdev@vger.kernel.org, dborkman@redhat.com, ffusco@redhat.com,
	fleitner@redhat.com, eric.dumazet@gmail.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41264 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587Ab3KUWUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 17:20:49 -0500
Content-Disposition: inline
In-Reply-To: <1385058197.1586.15.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/13 at 06:23pm, Ben Hutchings wrote:
> On Thu, 2013-11-21 at 19:13 +0100, Thomas Graf wrote:
> > +
> > +/**
> > + * V2:
> 
> This is not kernel-doc format so don't use '/**'.

I was hoping kernel-doc would pick it up but it doesn't.
I'll convert it.

> > +		if (info->genlhdr->version < OVS_DP_VER_FEATURES) {
> > +			WARN_ONCE(dp->user_features, "Dropping previously "
> > +				  "announced user features");
> 
> Log messages shouldn't be split like this as it makes them harder to
> find.  There should also be a newline at the end of the message.

Right, I'll fix this up. We seem to have many of these unfixed.

Jesse, do you want a full respin or just a v2 of this patch?
