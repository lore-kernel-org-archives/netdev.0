From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH 0/7] tcp: bugs and cleanup updated to 2.6.33-rc5
Date: Sat, 23 Jan 2010 00:27:32 -0500
Message-ID: <4B5A88C4.7050205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f186.google.com ([209.85.223.186]:61746 "EHLO
	mail-iw0-f186.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734Ab0AWF1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 00:27:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Combination of patches reported in October, November, December, and
January.  These patches fix perceived bugs, and other cleanup.

This code has had previous review and several months of limited testing.

Some portions were removed during the various TCPCT part 1 patch splits,
then were cut off by the sudden unexpected end of that merge window.
[03 Dec 2009]  I've restarted the sub-numbering (again).

Of particular interest are the TCPCT header extensions that already
appear in the next phase of testing with other platforms.  These patches
allow correct reception without data corruption.

The remainder of the original TCPCT part 2 will be merged with part 3.

These patches are against the current linux-2.6 tree.
