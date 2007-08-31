From: David Miller <davem@davemloft.net>
Subject: some weird corruption in net-2.6.24
Date: Thu, 30 Aug 2007 22:39:10 -0700 (PDT)
Message-ID: <20070830.223910.70218812.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57636
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932717AbXHaFjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 01:39:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Every so often some piece of userland dies, and often it's
bad enough that my desktop session logs out.

I've been trying to find some clues and it seems to happen
about as often as openswan rekeys my VPN, so one suspect
area is the netlink cleanups to xfrm_user.

I plan to do some auditing of those changes looking for
errors, but if someone can beat me to it... :-)

