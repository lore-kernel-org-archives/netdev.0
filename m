From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
	v2.6.26-rc3+
Date: Thu, 5 Jun 2008 16:22:44 +0200
Message-ID: <20080605142244.GA19216@elte.hu>
References: <20080603094057.GA29480@elte.hu> <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi> <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi> <20080603.150344.145518113.davem@davemloft.net> <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mcmanus@ducksong.com,
	peterz@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:38082 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755522AbYFEOXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 10:23:08 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wrote:

> [PATCH] tcp DEFER_ACCEPT: fix racy access to listen_sk

i unapplied the reverts then applied your fix, and got this hang after=20
1.5 hours of testing:

 titan:~> netstat -nt
 Active Internet connections (w/o servers)
 Proto Recv-Q Send-Q Local Address           Foreign Address   State
 tcp        0  65032 10.0.1.14:39454         10.0.1.19:3632    ESTABLIS=
HED

10.0.1.14 is this box, Core2Duo dual-core. 10.0.1.19 is another box wit=
h=20
16 CPUs.

	Ingo
