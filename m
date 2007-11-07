From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/2] fix for OOPS in pernet list operations if
	CONFIG_NET_NS undefined
Date: Wed, 7 Nov 2007 14:59:11 +0300
Message-ID: <20071107115911.GA10136@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, containers@lists.osdl.org,
	netdev@vger.kernel.org, clg@fr.ibm.com, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:51411 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752804AbXKGLzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 06:55:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches are addressed to the oops reported by the Cedric Le Goater
a week ago. The pernet_operations were discarder during kernel boot and
this breaks further operations as this 

Though, the patch from Pavel Emelyanov was partially reverted
by the Eric W. Biederman [commit 2b008b0a8e96b726c603c5e1a5a7a509b5f61e35]

So, I revert the Eric patch (actually, Eric one can be simply dropped) and
fix original code. There is no need for such complex code if CONFIG_NET_NS
is not defined.
