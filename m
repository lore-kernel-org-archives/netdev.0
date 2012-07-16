From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 0/2] Backward-compatibility for feature get/set
Date: Mon, 16 Jul 2012 23:17:21 +0100
Message-ID: <1342477041.2523.40.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52375 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754128Ab2GPWRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 18:17:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've committed fixes for another 2 bugs in features (-k/-K options):

- A silly regression introduced in 3.4, not covered by unit tests which
don't yet check the command output
- An older bug (really a defect in the ETHTOOL_GFLAGS API) which we can
work around

Ben.

Ben Hutchings (2):
  Remove bogus error message when changing offload settings on older
    kernels
  Fix reporting of VLAN tag offload flags for Linux 2.6.24-2.6.36

 ethtool.c |  101 ++++++++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 74 insertions(+), 27 deletions(-)

-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
