From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Preferred method for configuration
Date: Thu, 8 Aug 2013 11:44:39 +0200
Message-ID: <1375955079.2853.1.camel@deadeye.wl.decadent.org.uk>
References: <52032D5E.6070307@hhi.fraunhofer.de>
	 <1375940480.2424.135.camel@joe-AO722> <520332F4.5020206@hhi.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:54103 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934097Ab3HHJor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 05:44:47 -0400
In-Reply-To: <520332F4.5020206@hhi.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-08 at 07:56 +0200, Thomas Martitz wrote:
> Resent with list in CC.
> 
> Am 08.08.2013 07:41, schrieb Joe Perches:
> > On Thu, 2013-08-08 at 07:32 +0200, Thomas Martitz wrote:
> >> Hello,
> >>
> >> I'm developing a NIC driver and currently export some custom
> >> configuration settings and actions (e.g. enabling a loopback mode) via
> >> sysfs.
> >
> > Is there some reason you don't want to use ethtool?
> >
> >
> 
> It doesn't allow for custom settings does it? For standards stuff I'm 
> sure going to use ethtool.

You can always propose extensions to ethtool.

Note that the ethtool 'features' API already allows setting loopback and
there is a 'private flags' API through which you can expose up to 32
arbitrary named flags if they're really not at all generic.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
