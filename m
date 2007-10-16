From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/7] Next step in consolidating the IP fragment management
Date: Tue, 16 Oct 2007 17:46:23 +0400
Message-ID: <4714C0AF.1000209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33172 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758233AbXJPNs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 09:48:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set concerns the xxx_find() routine only. This one
is used to obtain the fragment queue depending on some
criteria, and this can be consolidated.

The consolidation goes step-by-step, consolidating one
sub-routine at a time, so some functions, exports and 
callbacks that are introduced in patches are temporary
and are removed in some subsequent patch.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
