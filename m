From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/3] wireless extensions improvements
Date: Wed, 24 Jun 2009 13:34:47 +0200
Message-ID: <20090624113447.441667549@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:52158 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759261AbZFXLi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 07:38:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series contains three improvements to wireless
extensions:
 1) make them network namespace aware, as discussed
    previously
 2) optimise the event sending code and fix a small
    heap information leak
 3) do some generic work and make it possible to send
    compat netlink events, and make wext do this

Because the third patch depends on the first two (it
could be made not to, if you wish) but touches generic
networking stuff, I'd like to have all of these included
in net-next instead of John's wireless tree, all the
other wireless work can be done independently of these.

johannes

