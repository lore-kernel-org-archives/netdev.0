From: Andreas Mohr <andi@lisas.de>
Subject: Re: [net-next v2 11/71] ni5010: Move the Racal-Interlan (Micom)
 driver
Date: Sun, 31 Jul 2011 18:57:02 +0200
Message-ID: <20110731165702.GA6334@rhlx01.hs-esslingen.de>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1312082850-24914-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Jan-Pascal van Best <janpascal@vanbest.org>,
	Andreas Mohr <andi@lisas.de>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:51671 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762Ab1GaRFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2011 13:05:20 -0400
Content-Disposition: inline
In-Reply-To: <1312082850-24914-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Jul 30, 2011 at 08:26:30PM -0700, Jeff Kirsher wrote:
> Moves the Racal-Interlan driver into drivers/net/ethernet/racal/ and
> make the necessary Kconfig and Makefile changes.

Acked-by: Andreas Mohr <andi@lisas.de>

---

Sorry, I had intended to reply to the original RFC,
but due to vacation backlog that got swept under the rug.

Since it's a simple move it seems to be fine.

One minor nit, however: since ni5210 (as seen in some other patch)
got moved to its respective NON-racal location (due to using a specific
chipset),
a short Kconfig addition explaining the whereabouts of ni5210
(and perhaps some other OEM chipset Racal cards?) would be useful.

Thank you for the probably long overdue cleanup of drivers/net/
into something more specific and thus much more easy on the eye :)

Andreas Mohr
