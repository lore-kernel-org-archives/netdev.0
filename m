From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: pci_device_id cleanups
Date: Wed, 20 Feb 2008 14:17:04 +0100
Message-ID: <20080220131704.GB18790@uranus.ravnborg.org>
References: <1203512031-14318-1-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	greg@kroah.com
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:43729 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752649AbYBTNQy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 08:16:54 -0500
Content-Disposition: inline
In-Reply-To: <1203512031-14318-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 20, 2008 at 01:53:36PM +0100, Jonas Bonn wrote:
> 
> The PCI_DEVICE_TABLE patch I sent earlier doesn't necessarily make
> much sense by itself... here is a set of patches that apply
> this macro, in turn moving a lot of this data into __devinitconst
> which is discardable in certain situations.
> Hopefully the benefit of this approach is a bit clearer now.
[shorter lines please..]

Can you please confirm that this does not break powerpc (64 bit)
as they have troubles with the constification..

	Sam
