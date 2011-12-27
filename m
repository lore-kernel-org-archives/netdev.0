From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: tc filter fw match and masks
Date: Mon, 26 Dec 2011 21:52:05 -0500
Message-ID: <1324954325.4401.78.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:58376 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752253Ab1L0CwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Dec 2011 21:52:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  While working on my test WAN project, I was quite surprised
to see only half my packets matching my filter.  I as using netfilter
marks which overlapped, e.g., inbound from Internet were
0011 0000
and interactive traffic was
0001 0001

I needed to switch to a u32 match as it appears the fw match does not
accept masks.  Is there any plan to change this? Thanks - John
