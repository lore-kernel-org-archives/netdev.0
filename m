From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCHv2 bridge 7/7] bridge:  Add the ability to show dump
 the vlan map from a bridge port
Date: Sat, 22 Sep 2012 18:15:32 +0100
Message-ID: <1348334132.2521.100.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
	 <1348058536-22607-8-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <shemminger@vyatta.com>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48522 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752815Ab2IVRPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 13:15:36 -0400
In-Reply-To: <1348058536-22607-8-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 08:42 -0400, Vlad Yasevich wrote:
> Using the RTM_GETLINK dump the vlan map of a given bridge port.
[...]

This enlarges the RTM_GETLINK response quite a bit.  I think perhaps
this should be optional, like IFLA_VFINFO_LIST is now.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
