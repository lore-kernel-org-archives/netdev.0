From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC 1/2] net:  Support getting/setting RX-FCS in drivers.
Date: Fri, 17 Jun 2011 17:00:34 +0100
Message-ID: <1308326434.2831.16.camel@bwh-desktop>
References: <1308285007-11302-1-git-send-email-greearb@candelatech.com>
	 <1308285007-11302-2-git-send-email-greearb@candelatech.com>
	 <1308313212.11457.62.camel@localhost>  <4DFB73B2.10506@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:35756 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036Ab1FQQAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 12:00:38 -0400
In-Reply-To: <4DFB73B2.10506@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-17 at 08:33 -0700, Ben Greear wrote:
> On 06/17/2011 05:20 AM, Ben Hutchings wrote:
> > On Thu, 2011-06-16 at 21:30 -0700, greearb@candelatech.com wrote:
> >> From: Ben Greear<greearb@candelatech.com>
> >>
> >> This will allow us to enable/disable having the Ethernet
> >> frame checksum appended to the skb.  Enabling this is
> >> useful when sniffing packets.
> >>
> >> In particular, this can be used to test logic that allows
> >> a NIC to receive all frames, even ones with bad checksums.
[...]
> > And as Michal says, this could reasonably be a feature not an entirely
> > separate flag.  I'm not sure it's that important to have debugging flags
> > in features, but I also don't want to have 2 commands per flag...
> 
> I'm not sure it really counts as a feature, and I've no desire to tangle
> with the effort to extend features beyond 32 bits.

There are several people wanting to add new flags, so between you I'm
sure you can manage it.

> Maybe we could have a new
> ethtool command that took a struct with two args, so we can "set flag-foo val"
> instead of 'enable-flag-foo' and 'disable-flag-foo'?
> 
> That should be only one additional method for the drivers to implement, and
> can be used for the other patches I have planned as well.

Whereas implementing an extra feature toggle now requires zero extra
methods.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

