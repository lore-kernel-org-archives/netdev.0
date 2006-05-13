From: Paul Mackerras <paulus@samba.org>
Subject: Re: [Bugme-new] [Bug 6530] New: MAINLINE
Date: Sat, 13 May 2006 15:27:24 +1000
Message-ID: <17509.28220.977266.68155@cargo.ozlabs.ibm.com>
References: <200605100920.k4A9KC91018259@fire-2.osdl.org>
	<20060510023357.0d1260ee.akpm@osdl.org>
	<17505.49174.848331.686297@cargo.ozlabs.ibm.com>
	<1147326683.29448.80.camel@tahini.andynet.net>
	<20060510225633.1b53d4f8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andy Gay <andy@andynet.net>, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39145 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S932335AbWEMF1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 May 2006 01:27:34 -0400
To: xeb@mail.ru
In-Reply-To: <20060510225633.1b53d4f8.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton writes:

> xeb (who forgot to do reply-to-all) tells me that pptpd uses ptys.

I tried to replicate this using pppd running on a pty, with a
"charshunt" process on the master side of the pty transferring
characters between it and a socket.  I didn't see any freezeups in
either direction.  So - precise details on how to replicate this would
be appreciated.

Paul.
