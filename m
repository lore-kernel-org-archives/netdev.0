From: Brandon Philips <bphilips@suse.de>
Subject: Re: [PATCH] sky2: set carrier off in probe
Date: Thu, 29 Oct 2009 21:30:50 -0700
Message-ID: <20091030043050.GB3380@jenkins.home.ifup.org>
References: <20091029235807.GF3228@jenkins.home.ifup.org>
 <20091029200905.00f4c13d@nehalam>
 <20091030035128.GA3380@jenkins.home.ifup.org>
 <20091029.211219.182331672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58109 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751632AbZJ3Edp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2009 00:33:45 -0400
Content-Disposition: inline
In-Reply-To: <20091029.211219.182331672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21:12 Thu 29 Oct 2009, David Miller wrote:
> From: Brandon Philips <bphilips@suse.de>
> Date: Thu, 29 Oct 2009 20:51:28 -0700
> 
> > The right thing to do is up the interface first before looking at the
> > the Link state, and I told them to do that, but I figured that this
> > patch made sense too to fix the initial buglet.
> 
> It is not valid to expect link status before bringing the interface
> up.

I agree the link state makes no sense when the interface isn't up.
The buglet is that other drivers seem to report "Link detected: no"
after probe while sky2 doesn't.

I don't have a strong feeling on this patch since the customer fixed
their script to do the right thing.

Cheers,

	Brandon
