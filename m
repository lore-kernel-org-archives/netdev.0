From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] sctp: Fix mangled IPv4 addresses on a IPv6 listening
 socket
Date: Thu, 28 May 2015 08:58:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB4177C@AcuExch.aculab.com>
References: <20150526233017.GB22391@obsidianresearch.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB408FE@AcuExch.aculab.com>
 <55658F9D.6030404@iogearbox.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CB409AD@AcuExch.aculab.com>
 <20150527153226.GA9909@obsidianresearch.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB40D32@AcuExch.aculab.com>
 <20150527163157.GA15041@obsidianresearch.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB40E15@AcuExch.aculab.com>
 <20150527170440.GA15308@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Daniel Borkmann' <daniel@iogearbox.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Jason Gunthorpe' <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:51188 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949AbbE1JAY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 05:00:24 -0400
In-Reply-To: <20150527170440.GA15308@obsidianresearch.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Gunthorpe
> Sent: 27 May 2015 18:05
> On Wed, May 27, 2015 at 04:41:18PM +0000, David Laight wrote:
> 
> > The code will be sleeping in kernel_accept() and later calls
> > kernel_getpeername().
> > The code is used for both TCP and SCTP and this part is common (using
> > the TCP semantics).
> 
> getpeername uses a different flow, it calls into inet6_getname which
> will always return the AF_INET6 version.

Ok, that explains why I hadn't seen the problem.
It also means I don't have to worry about it.

	David
