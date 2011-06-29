From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Wed, 29 Jun 2011 16:34:23 -0700
Message-ID: <20110629163423.1d73b0ef@nehalam.ftrdhcpuser.net>
References: <20110628150257.GB126252@jupiter.n2.diac24.net>
	<20110628081015.1b06a3f0@nehalam.ftrdhcpuser.net>
	<20110628160018.GC126252@jupiter.n2.diac24.net>
	<BANLkTikDqjErqBmfwrN6SJPgPjmmMfJw7g@mail.gmail.com>
	<20110628185811.GA2121496@jupiter.n2.diac24.net>
	<BANLkTi=goXU4SpP6dxX9C+YeLcVMEkcKHw@mail.gmail.com>
	<20110628202200.GB2121496@jupiter.n2.diac24.net>
	<BANLkTim1owW7iMS3hgKhm7DzTzE4X-jxHA@mail.gmail.com>
	<20110628210434.GD2121496@jupiter.n2.diac24.net>
	<BANLkTikN_TPPcyywVT5W9CrGAFJX8qQiyQ@mail.gmail.com>
	<20110628214637.GE2121496@jupiter.n2.diac24.net>
	<BANLkTi=4-xYNyaBOzeL04VioK8D0Q8secg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56056 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756566Ab1F2XfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 19:35:23 -0400
In-Reply-To: <BANLkTi=4-xYNyaBOzeL04VioK8D0Q8secg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem is that the damn 802.1 committees keep loading up protocols
on the same multicast address range. Trying to solve a design committee 
problem in the kernel is not going to make anybody happy.

I am happy with the simple solution of:
  no STP == Hub
  STP    == Bridge
These are both well know configurations and are blessed by standards.

