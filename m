From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCHv2 bridge 7/7] bridge: Add the ability to show dump
 the vlan map from a bridge port
Date: Sat, 22 Sep 2012 13:05:53 -0700
Message-ID: <20120922130553.3d7e0299@nehalam.linuxnetplumber.net>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
	<1348058536-22607-8-git-send-email-vyasevic@redhat.com>
	<1348334132.2521.100.camel@bwh-desktop.uk.solarflarecom.com>
	<20120922.132747.1937291269030903700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, vyasevic@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42638 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751645Ab2IVUGX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2012 16:06:23 -0400
In-Reply-To: <20120922.132747.1937291269030903700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 22 Sep 2012 13:27:47 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Sat, 22 Sep 2012 18:15:32 +0100
> 
> > On Wed, 2012-09-19 at 08:42 -0400, Vlad Yasevich wrote:
> >> Using the RTM_GETLINK dump the vlan map of a given bridge port.
> > [...]
> > 
> > This enlarges the RTM_GETLINK response quite a bit.  I think perhaps
> > this should be optional, like IFLA_VFINFO_LIST is now.
> 
> Completely agreed.

Since most users won't use it, it should be not necessary to include
it if the map is blank.
