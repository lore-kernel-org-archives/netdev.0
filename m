From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/12 net-2.6.25] [NETNS]: Routing namespacing on IP output
 path.
Date: Tue, 22 Jan 2008 18:58:54 +0300
Message-ID: <479612BE.8030409@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, devel@openvz.org,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:54399 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752333AbYAVP66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 10:58:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set introduces namespacing in the IP output path. The namespace is
added to all routing API functions except ones with a valid socket. This
is very intrusive.

Routing cache is virtualized as a part of this efforts, though the hash
function is not tuned to use namespace id. This not required to work in
initial namespace.

ICMP replies now also use correct namespace.

Signed-off-by: Denis V. Lunev <den@openvz.org>


