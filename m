From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Subject: UNIX sockets kernel panic
Date: Thu, 6 Nov 2008 00:14:46 +0000
Message-ID: <20081106001445.GA5595@shorty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: a.bittau@cs.ucl.ac.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:14142 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140AbYKFANq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 19:13:46 -0500
Received: by ey-out-2122.google.com with SMTP id 6so137486eyi.37
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2008 16:13:45 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following code causes a kernel panic on Linux 2.6.26:
http://darkircop.org/unix.c

I haven't investigated the bug so I'm not sure what is causing it, and
don't know if it's exploitable.  The code passes unix sockets from one
process to another using unix sockets.  The bug probably has to do with
closing file descriptors.

[I'm not subscribed to the list so please CC me if you answer.]
