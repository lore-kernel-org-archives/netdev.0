From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] team: add ethtool support
Date: Thu, 10 Jan 2013 16:27:39 +0000
Message-ID: <1357835259.2712.4.camel@bwh-desktop.uk.solarflarecom.com>
References: <1356830366-991-1-git-send-email-fbl@redhat.com>
	 <20121229172945.25a09fc8@nehalam.linuxnetplumber.net>
	 <20121230014403.GA2077@obelix.rh>
	 <1356834716.21409.6258.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Flavio Leitner <fbl@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29911 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417Ab3AJQ1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 11:27:46 -0500
In-Reply-To: <1356834716.21409.6258.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-12-29 at 18:31 -0800, Eric Dumazet wrote:
> On Sat, 2012-12-29 at 23:44 -0200, Flavio Leitner wrote:
> 
> > Speaking as a support engineer, it's a lot easier to grab ethtool -S and
> > see everything than grab two or more outputs.
> > 
> 
> I agree its very convenient.
> 
> I have a patch to add GRO statistics at the core layer, in the ethtool
> -S stats. 
> 
> I was about to ask netdev guys what they think of this idea ?
[...]

I would like to make these statistics available *but* I would prefer to
see a plan for properly integrating the basic statistics
(net_device_stats/rtnl_link_stats64), additional core statistics (such
as these) and driver-specific statistics.

It's annoying that users have to use different tools to get these, and
adding core statistics to ethtool (currently driver-specific) is just
going to be more confusing.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
