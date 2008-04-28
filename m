From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP slowdown in 2.6.25?
Date: Mon, 28 Apr 2008 17:42:45 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804281728280.1888@wrl-59.cs.helsinki.fi>
References: <1209384733.6904.12.camel@gentoo-jocke.transmode.se>
 <1209389586.6904.17.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53787 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932210AbYD1Omr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 10:42:47 -0400
In-Reply-To: <1209389586.6904.17.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Apr 2008, Joakim Tjernlund wrote:
> On Mon, 2008-04-28 at 14:12 +0200, Joakim Tjernlund wrote:
> > After upgrading from 2.6.23 to 2.6.25 I am seeing a big slow down on
> > our old www server. Stracing shows lots of EAGAIN but i not sure
> > these are relevant. I got no idea where to start looking so
> > I would appreciate some pointers. Perhaps this is a know issue?
> > 
> > CPU is a PowerPC, mpc8321, network driver ucc_geth
> 
> Some info:
> Even ftp transfers takes forever, but only in one direction: from the
> node with kernel 2.6.25 to some other host. Strace show me that
> write(2) hangs for long periods before succeeding to transmit 
> the data.

Since it's easy, can you quickly try to if setting tcp_sack sysctl to 0 
makes any difference (I made a surgery there, perhaps some bug in there 
could cause TCP to recover by RTO multiple times in a row, that should 
be visible in tcpdump as well)?

Do you have network namespaces enabled in .config?

Netfilter/iptables involved?

To some specific or "any" other host? How long is "long"?


-- 
 i.
