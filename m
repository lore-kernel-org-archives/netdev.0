From: Sebastian Kuzminsky <seb@highlab.com>
Subject: Re: bug in tcp?
Date: Mon, 16 Apr 2007 22:42:22 -0600
Message-ID: <E1HdfWI-0005Wp-Lx@highlab.com>
References: <E1HdZgM-0001n2-F0@highlab.com> <20070416155038.3bfa5104@freekitty> <E1HdaGU-0001sZ-JS@highlab.com> <20070416163031.6b87764c@dxpl.pdx.osdl.net> <46244D4A.2010209@psc.edu>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Sebastian Kuzminsky <seb@highlab.com>
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sccrmhc14.comcast.net ([204.127.200.84]:59330 "EHLO
	sccrmhc14.comcast.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031068AbXDQEm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 00:42:28 -0400
In-reply-to: <46244D4A.2010209@psc.edu> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner <jheffner@psc.edu> wrote:
> Stephen Hemminger wrote:
> > A guess: maybe something related to a PAWS wraparound problem.
> > Does turning off sysctl net.ipv4.tcp_timestamps fix it?
> 
> That was my first thought too (aside from netfilter), but a failed PAWS 
> check should not result in a reset..

All three of the systems where I saw the problems earlier did have some
netfilter rules up and running....

All tests I'm doing now have netfilter compiled in but no rules set
(INPUT, FORWARD, and OUTPUT are all empty, and the policies are all
ACCEPT).


-- 
Sebastian Kuzminsky
