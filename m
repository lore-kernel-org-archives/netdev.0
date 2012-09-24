From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCHv2 bridge 7/7] bridge: Add the ability to show dump
 the vlan map from a bridge port
Date: Mon, 24 Sep 2012 20:39:15 +0200
Message-ID: <1348511955.10741.4.camel@deadeye.wl.decadent.org.uk>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
	 <1348058536-22607-8-git-send-email-vyasevic@redhat.com>
	 <1348334132.2521.100.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120922.132747.1937291269030903700.davem@davemloft.net>
	 <20120922130553.3d7e0299@nehalam.linuxnetplumber.net>
	 <50606500.1040102@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10405 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757310Ab2IXSjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 14:39:20 -0400
In-Reply-To: <50606500.1040102@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 09:49 -0400, Vlad Yasevich wrote:
> On 09/22/2012 04:05 PM, Stephen Hemminger wrote:
> > On Sat, 22 Sep 2012 13:27:47 -0400 (EDT)
> > David Miller <davem@davemloft.net> wrote:
> >
> >> From: Ben Hutchings <bhutchings@solarflare.com>
> >> Date: Sat, 22 Sep 2012 18:15:32 +0100
> >>
> >>> On Wed, 2012-09-19 at 08:42 -0400, Vlad Yasevich wrote:
> >>>> Using the RTM_GETLINK dump the vlan map of a given bridge port.
> >>> [...]
> >>>
> >>> This enlarges the RTM_GETLINK response quite a bit.  I think perhaps
> >>> this should be optional, like IFLA_VFINFO_LIST is now.
> >>
> >> Completely agreed.
> >
> > Since most users won't use it, it should be not necessary to include
> > it if the map is blank.
> >
> 
> Response is included only for AF_BRIDGE calls (proably used by STP 
> implementation) and only when vlan filtering is configured.
> 
> I do see the point though and can add a filter for this.

I thought the per-AF stuff was included by default (or at least what
most clients ask for).  If not then this is probably fine.
IFLA_VFINFO_LIST was causing glibc's queries to fail and that must be
avoided.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
