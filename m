From: nhorman@tuxdriver.com
Subject: [PATCH] bonding: various fixes for bonding, netpoll & netconsole
Date: Tue, 12 Oct 2010 16:29:32 -0400
Message-ID: <1286915377-1612-1-git-send-email-nhorman@tuxdriver.com>
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	davem@davemloft.net, andy@greyhouse.net, amwang@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe-076-182-075-229.nc.res.rr.com ([76.182.75.229]:50305 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751773Ab0JLWSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 18:18:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry if this is a resend for some, a bad git-send-email config caused some
rejections, so I'm resending.

A few months back, an attempt was made to enable netpoll over bonding, so that
netconsole could be used over bonded interfaces.  This worked in the steady
state, but had several deadlocks in various failover conditions.  I've gone
through the bonding code, and fixed up those deadlocks, along with several other
problems noted along the way, which caused other issues with netpoll+bonding.
With this patch series, netpoll works with bonding in all modes accross all
slaves during failover conditions.  It also allows fixes some deadlock
conditions in the netconsole code itself.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


