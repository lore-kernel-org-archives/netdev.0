From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [NET-NEXT PATCH] igb: Add support for pci-e Advanced Error
 Reporting
Date: Wed, 26 Nov 2008 16:54:14 -0800
Message-ID: <20081126165414.673a35bb@extreme>
References: <20081127000441.22613.99805.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35928 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750696AbYK0Ay1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 19:54:27 -0500
In-Reply-To: <20081127000441.22613.99805.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Nov 2008 16:04:41 -0800
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Add the calls necessary to enable advanced error reporting for igb on
> systems with AER enabled.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Does kernel AER work without mmconfig?
I ran into problems and gave up trying to get it work with sky2
because too many systems don't have working PCI mmconfig access
and the necessary registers are >= 256 and therefore won't work
without mmconfig.
