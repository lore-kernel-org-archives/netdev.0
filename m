From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 0/3] Regularise handling of offload flags
Date: Mon, 21 Feb 2011 16:54:42 +0000
Message-ID: <1298307282.2608.47.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:56584 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab1BUQyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 11:54:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is partly inspired by the recent changes to regularise
the relationship between ethtool offload control and net_device feature
flags, though I started on it earlier.

I don't intend to apply these changes until after the kernel and ethtool
v2.6.38 releases.  In the mean time, I would appreciate testing and
feedback.

Ben.

Ben Hutchings (3):
  ethtool-copy.h: sync with net-next-2.6
  ethtool: Regularise handling of offload flags
  ethtool: Report additional offload flag changes made automatically

 ethtool-copy.h |   89 +++++++++++-
 ethtool-util.h |   30 ++++
 ethtool.c      |  465 ++++++++++++++++++++++++++++----------------------------
 3 files changed, 352 insertions(+), 232 deletions(-)

-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

