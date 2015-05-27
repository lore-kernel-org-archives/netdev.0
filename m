From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] sctp: Fix mangled IPv4 addresses on a IPv6 listening
 socket
Date: Wed, 27 May 2015 10:11:22 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB409AD@AcuExch.aculab.com>
References: <20150526233017.GB22391@obsidianresearch.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB408FE@AcuExch.aculab.com>
 <55658F9D.6030404@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Daniel Borkmann' <daniel@iogearbox.net>,
	'Jason Gunthorpe' <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.191]:62938 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071AbbE0KNG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 06:13:06 -0400
In-Reply-To: <55658F9D.6030404@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann
> Sent: 27 May 2015 10:34
...
> >> Fixes: 299ee123e198 (sctp: Fixup v4mapped behaviour to comply with Sock API)
> > ...
> >> This bugfix should be a candidate for -stable
> >
> > Anyone know off-hand which kernel releases are affected?
> > I'm going to have to note this in the release notes for one of our products.
> 
> Ever heard of git-describe(1) ? ;)
> 
> git describe 299ee123e19889d511092347f5fc14db0f10e3a6
> v3.16-rc7-1525-g299ee12

Probably last time I asked the same question :-)
Since I don't spend all day fighting git, I don't know all the sub-commands.

In any case it looks like I can escape by turning off
SCTP_I_WANT_MAPPED_V4_ADDR for kernels 3.17 through 4.0.

	David
