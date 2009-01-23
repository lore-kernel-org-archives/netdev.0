From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 0/21][next] qlge: Clean up and add firmware support.
Date: Fri, 23 Jan 2009 07:15:13 -0800
Message-ID: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48388 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbZAWPQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:16:18 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series does 3 things for 2.6.30:

1) Adds in device ID 8000.  Note that it replaces 8012. We don't want to
carry forward 8012 support unless forced to. If necessary we'll add it
in disto. It was an early device that didn't have firmware support and
different flash layout.

2) Removes driver link management and adds firmware support of link
management.

3) A lot of clean up.

Cheers,

Ron

