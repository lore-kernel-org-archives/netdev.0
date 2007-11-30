From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/4 net-2.6.15][UNIX] Make unix sysctls per-namespace
Date: Fri, 30 Nov 2007 19:23:53 +0300
Message-ID: <47503919.8060103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58044 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762526AbXK3QZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 11:25:31 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Herbert, guys.

Since you have accepted some net-namespaces-related work
from Eric (sysctl namespaces), I hope, that you can pay 
some attention to further work in this direction.

This set makes the unix-sockets sysctls (currently this
includes the sys/net/unix/max_dgram_qlen only) per net
namespace.

I splitted it into four patches, to make the review simpler.
Hope that this split will help.

This set resembles the one Eric has in his netns tree, but
differs in some (maybe minor) ways.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
