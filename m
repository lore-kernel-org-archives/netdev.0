From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] e1000: enhance frame fragment detection
Date: Wed, 20 Jan 2010 16:21:35 -0800 (PST)
Message-ID: <20100120.162135.41689739.davem@davemloft.net>
References: <20100120001511.25175.55030.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com, nhorman@tuxdriver.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33275
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754785Ab0AUAVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 19:21:25 -0500
In-Reply-To: <20100120001511.25175.55030.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 19 Jan 2010 16:15:38 -0800

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Originally From: Neil Horman <nhorman@tuxdriver.com>
> Modified by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Hey all-
> 	A security discussion was recently given:
> http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html
> And a patch that I submitted awhile back was brought up.  Apparently some of
> their testing revealed that they were able to force a buffer fragment in e1000
> in which the trailing fragment was greater than 4 bytes.  As a result the
> fragment check I introduced failed to detect the fragement and a partial
> invalid frame was passed up into the network stack.  I've written this patch
> to correct it.  I'm in the process of testing it now, but it makes good
> logical sense to me.  Effectively it maintains a per-adapter state variable
> which detects a non-EOP frame, and discards it and subsequent non-EOP frames
> leading up to _and_ _including_ the next positive-EOP frame (as it is by
> definition the last fragment).  This should prevent any and all partial frames
> from entering the network stack from e1000.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
