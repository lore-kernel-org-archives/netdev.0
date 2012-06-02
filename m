From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 0/7] Generic netdev features support
Date: Sat, 2 Jun 2012 01:33:47 +0100
Message-ID: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Mahesh Bandewar <maheshb@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35741 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759987Ab2FBAdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 20:33:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds support for the not-so-new generic netdev features
ethtool API, along with some test infrastructure and test cases to check
that it works with old and new kernel versions.  I'm still not convinced
that there are enough test cases, but I've held this back for too damn
long already.

I'd like to include these changes in an ethtool 3.4 release by the end
of next week, so let me know if there's anything wrong with them.

Ben.

Ben Hutchings (7):
  Run tests in-process
  Add output file parameter to dump_hex() and make it extern
  test: Add test_ioctl() function to support a mock send_ioctl()
  Add unit tests for setting offload features (old API)
  Regularise offload feature settings
  Report when offload feature changes are not exactly as requested
  Change -k/-K options to use ETHTOOL_{G,S}FEATURES

 .gitignore      |    2 +-
 Makefile.am     |   10 +-
 ethtool.8.in    |   31 +--
 ethtool.c       |  668 +++++++++++++++++++++++++++++++++++--------------------
 internal.h      |   72 ++++++
 test-cmdline.c  |   14 +-
 test-common.c   |  357 +++++++++++++++++++++++++++---
 test-features.c |  516 ++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 1358 insertions(+), 312 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
