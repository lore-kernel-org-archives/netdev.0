From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] New driver "sfc" for Solarstorm SFC4000 controller (try #7)
Date: Wed, 5 Mar 2008 14:22:04 +0000
Message-ID: <20080305142203.GQ2988@solarflare.com>
References: <1204572175.16248.5.camel@localhost.localdomain> <20080303123937.2d72d7e8@extreme> <20080303211743.GG2988@solarflare.com> <20080303.132941.176565936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, dcbw@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pythagoras.zen.co.uk ([212.23.3.140]:40601 "EHLO
	pythagoras.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbYCEOWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 09:22:19 -0500
Content-Disposition: inline
In-Reply-To: <20080303.132941.176565936.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

We concede that the driver is currently too large to be properly
reviewed in one go.

We propose to:

1. Remove what we can - i.e. internal HW support, extraneous comments,
unused HW register defines, and non-essential peripheral driver features
such as sensor support - leaving a minimal network driver.

2. Post the minimal driver in sub-100K patches to netdev.  This
minimal driver will still require several patches, but future patches
should represent independent pieces of functionality.

If you can see reasons why this will still not get us to a point where
a review can take place then please tell us what else is required.

We hope to complete this work within the next few days.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
