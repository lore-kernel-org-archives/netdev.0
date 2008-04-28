From: Andrew Morton <akpm@linux-foundation.org>
Subject: useless tcp maybe-bug report
Date: Mon, 28 Apr 2008 01:40:49 -0700
Message-ID: <20080428014049.eee1a533.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39322 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751744AbYD1IlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 04:41:20 -0400
Received: from imap1.linux-foundation.org (imap1.linux-foundation.org [140.211.169.55])
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id m3S8envP022889
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 01:40:51 -0700
Received: from y.localdomain (localhost [127.0.0.1])
	by imap1.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with SMTP id m3S8enoF016712
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 01:40:49 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just fired up latest mainline plus the 300-odd patches which I'm about to
send Linuswards on a mac g5.

I use that g5 as a distcc server.  I'm now seeing this:

distcc[13554] (dcc_writex) ERROR: failed to write: Connection reset by peer
distcc[13554] (dcc_writex) ERROR: failed to write: Broken pipe
distcc[13554] Warning: failed to distribute net/atm/clip.mod.c to g5/32, running locally instead

about once per allmodconfig build.  The client kernel is 2.6.24.3-34.fc8
and has never changed.

Thing is, these messages are unusual.  I suspect that Something Is Up with
that g5, perhaps its networking.

There are no signs of problems in the g5's dmesg.
