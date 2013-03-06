From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 8139too: send NETDEV_CHANGE manually when autoneg is disabled
Date: Wed, 6 Mar 2013 22:35:11 +0100
Message-ID: <20130306213511.GA11331@electric-eye.fr.zoreil.com>
References: <1362596784-19443-1-git-send-email-vfalico@redhat.com> <1362601372.3126.23.camel@bwh-desktop.uk.solarflarecom.com> <20130306.155323.344491888348815531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, vfalico@redhat.com,
	netdev@vger.kernel.org, wfp5p@virginia.edu, jasowang@redhat.com,
	junchangwang@gmail.com, greearb@candelatech.com, ivecera@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41339 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754065Ab3CFVf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 16:35:59 -0500
Content-Disposition: inline
In-Reply-To: <20130306.155323.344491888348815531.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
> From: Ben Hutchings <bhutchings@solarflare.com>
[...]
> > Isn't this really a bug in mii_check_media()?  It shouldn't shortcut the
> > calls to netif_carrier_{off,on}() just because mii->force_media is set.
> 
> I think mii_check_media() is responsible for handling this too.

There are a few drivers that use mii_ethtool_sset as 8139too does
while not relying upon mii_check_media.

What ought to be done for those ?

-- 
Ueimor
