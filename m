From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: qdisc and down links (regression)
Date: Thu, 7 Aug 2008 14:30:36 -0700
Message-ID: <20080807143036.1ae10482@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vgr.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50192 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751284AbYHGVai (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 17:30:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before the mulitqueue changes in 2.6.27-rc it was possible to setup
queueing disciplines before the link came up (carrier active). This
no longer works. If link is down, the qdisc is the noop_qdisc and
any configuration changes don't seem to be shown.

This probably will break ISP's (and other users whose links aren't always
on) that use traffic shaping.

For example, try wondershaper or similar script before boot; all the
tc commands will fail.
