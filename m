From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH] sctp: Fix mangled IPv4 addresses on a IPv6 listening
 socket
Date: Wed, 27 May 2015 09:32:26 -0600
Message-ID: <20150527153226.GA9909@obsidianresearch.com>
References: <20150526233017.GB22391@obsidianresearch.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB408FE@AcuExch.aculab.com>
 <55658F9D.6030404@iogearbox.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CB409AD@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Daniel Borkmann' <daniel@iogearbox.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:56224 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751679AbbE0Pcx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2015 11:32:53 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB409AD@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2015 at 10:11:22AM +0000, David Laight wrote:

> In any case it looks like I can escape by turning off
> SCTP_I_WANT_MAPPED_V4_ADDR for kernels 3.17 through 4.0.

Just be aware that option is unusable on kernels without 299ee.

I fixed everything wrong I saw, but that doesn't mean it works
100%. Honestly, I don't think anyone has ever used it.

Jason
