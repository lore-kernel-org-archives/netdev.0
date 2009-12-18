From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is  dropped after ~40 seconds
Date: Fri, 18 Dec 2009 00:22:22 -0800
Message-ID: <adaoclw3d4x.fsf@roland-alpha.cisco.com>
References: <bug-14794-10286@http.bugzilla.kernel.org/>
	<20091216154713.f082e7cf.akpm@linux-foundation.org>
	<4B2A9A40.90203@freemail.hu>
	<20091217132451.b168a796.akpm@linux-foundation.org>
	<4B2AA64C.50709@gmail.com> <4B2B35B7.6060703@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: =?utf-8?Q?N=C3=A9meth_M=C3=A1rton?= <nm127@freemail.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:46598 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbZLRIW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 03:22:26 -0500
In-Reply-To: <4B2B35B7.6060703@freemail.hu> (=?utf-8?Q?=22N=C3=A9meth_M?=
 =?utf-8?Q?=C3=A1rton=22's?= message of
	"Fri, 18 Dec 2009 08:56:39 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > Unfortunately reverting the commit 61cbe54d9479ad98283b2dda686deae4c34b2d59 on
 > top of 2.6.32 does not solve the problem.

By the way, one thing you could double check is that 61cbe54d is
definitely bad, and the 61cbe54d tree with that commit reverted is
definitely good.

 - R.
