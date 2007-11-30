From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/4] basic infrastructure for routing in the network
	namespace
Date: Fri, 30 Nov 2007 19:06:09 +0300
Message-ID: <20071130160609.GA10126@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, netdev@vger.kernel.org, davem@davemloft.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:52613 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761824AbXK3QFS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 11:05:18 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set of patches provides a basic infrastructure for routing and further
IPv4 virtualization. Initialize flowi with a init namespace. Proper namespace
setup will follow step-by-step.
