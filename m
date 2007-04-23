From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/5 2.6.21-rc7] l2tp: introduce PPP over L2TP driver
Date: Mon, 23 Apr 2007 17:07:40 +0200
Message-ID: <462CCBBC.1010009@trash.net>
References: <200704231255.l3NCte3Y028365@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48907 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555AbXDWPHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 11:07:46 -0400
In-Reply-To: <200704231255.l3NCte3Y028365@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> This patch set adds a driver for PPP over L2TP. Patches to follow.
> 
> The following changes have been made since the previous version
> submitted 23-MAR-07, addressing review comments received so far:-
> 
> - Fold makefile changes into the patches that add new source files.


The reason to do this was to keep the tree compiling at all stages,
which this patchset still doesn't do. You should first add your changes
to other files (like skb_queue_walk_safe, ppp headers, ...), then
add the code that uses them.

