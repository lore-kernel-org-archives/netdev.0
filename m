From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/4] netns: basic infrastructure for routing in the network
	namespace
Date: Tue, 4 Dec 2007 12:50:42 +0300
Message-ID: <20071204095042.GA5992@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, containers@lists.osdl.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:61686 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752879AbXLDJtm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 04:49:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches provides a basic infrastructure for routing and further
IPv4 virtualization. Initialize flowi with a init namespace. Proper namespace
setup will follow step-by-step.

These patches has been originally sent to Herbert.
