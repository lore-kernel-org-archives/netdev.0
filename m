From: Kostya B <bkostya@hotmail.com>
Subject: LRO ip_summed
Date: Sun, 3 Feb 2008 09:48:17 +0000
Message-ID: <BAY121-W366A043ECDC160494B1EFAB6320@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1255"
Content-Transfer-Encoding: 8bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s31.bay0.hotmail.com ([65.54.246.103]:22710 "EHLO
	bay0-omc1-s31.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760488AbYBCJsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 04:48:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

The mail is related to the way LRO manipulates the ip_summed value. Could anybody (author) explain why to overwrite the original value of skb->ip_summed, when it's processing by __lro_proc_skb ?
E.g. in out: label

Why not to preserve the coherency of csum status of each incoming to LRO packet, the same way the IP defragmentation does? That means - all skb in descriptor have the same value of ip_summed.

Tnx,
- Kostya

_________________________________________________________________
Express yourself instantly with MSN Messenger! Download today it's FREE!
http://messenger.msn.click-url.com/go/onm00200471ave/direct/01/
