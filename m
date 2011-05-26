From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] atm: expose ATM device index in sysfs
Date: Thu, 26 May 2011 12:06:51 -0700
Message-ID: <20110526190651.GA7627@kroah.com>
References: <1306432057.3151.10.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Chas Williams <chas@cmf.nrl.navy.mil>,
	David Woodhouse <dwmw2@infradead.org>, stable@kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3.smtp.messagingengine.com ([66.111.4.27]:44158 "EHLO
	out3.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758012Ab1EZTFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 15:05:54 -0400
Content-Disposition: inline
In-Reply-To: <1306432057.3151.10.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2011 at 12:47:36PM -0500, Dan Williams wrote:
> It's current exposed only through /proc which besides requiring
> screen-scraping doesn't allow userspace to distinguish between two
> identical ATM adapters with different ATM indexes.  The ATM device index
> is required when using PPPoATM on a system with multiple ATM adapters.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> ---
> 
> PS: -> stable too since it's a minimal change with no backwards
> incompatibility and I'd like to rely on this attribute in NetworkManager

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
