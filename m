From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 0/5] Add --version option and fix some bugs in
 show_usage()
Date: Mon, 21 Feb 2011 19:16:49 +0000
Message-ID: <1298315809.2608.68.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10103 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab1BUTQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 14:16:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every command-line tool needs a --version option, right?  And while
looking at the existing option parsing and usage messages I found and
fixed some bugs.

Ben.

Ben Hutchings (5):
  ethtool: Split show_usage() into two functions
  ethtool: Report an error if given an unrecognised option
  ethtool: Allow for long options with no short option and without a
    device name
  ethtool: Indent the no-options usage line consistently with the
    others
  ethtool: Add --version option

 ethtool.8.in |    5 ++
 ethtool.c    |  165 +++++++++++++++++++++++++++++++--------------------------
 2 files changed, 95 insertions(+), 75 deletions(-)

-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

