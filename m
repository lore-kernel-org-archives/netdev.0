From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] team: add support to get speed via ethtool
Date: Sat, 7 Mar 2015 07:30:24 -0500
Message-ID: <20150307123024.GF502@gospo.home.greyhouse.net>
References: <1425592115-1750-1-git-send-email-sridhar.samudrala@intel.com>
 <20150306.002410.1359006818497057668.davem@davemloft.net>
 <20150307031013.GC502@gospo.home.greyhouse.net>
 <20150307.011249.990503044534249616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sridhar.samudrala@intel.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:46408 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbbCGMa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 07:30:29 -0500
Received: by qcxr5 with SMTP id r5so56754172qcx.13
        for <netdev@vger.kernel.org>; Sat, 07 Mar 2015 04:30:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150307.011249.990503044534249616.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 07, 2015 at 01:12:49AM -0500, David Miller wrote:
> From: Andy Gospodarek <gospo@cumulusnetworks.com>
> Date: Fri, 6 Mar 2015 22:10:13 -0500
> 
> > but this was not possible for SNMP-based tools that are not aware of
> > the aggregation of ports on the host.
> 
> The suggested value to report HAS NO MEANING.
> 
> If you just add the speeds up that's complete bullshit.
> 
> Nothing prevents the SNMP userland from doing the right thing
> and figuring out the geography and perhaps even exporting
> that geography to SNMP querying agents.

I was actually pretty surprised that this patch stuck when I first
posted it for that very reason.  I'm quite sure I posted this as a RHEL
customer put in a request for the feature, but since I'm clearly less
invested today in that subset of Linux users than I was when I posted
that patch it doesn't bother me one bit if it is pulled!
