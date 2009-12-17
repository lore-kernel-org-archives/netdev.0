From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is
 dropped after ~40 seconds
Date: Thu, 17 Dec 2009 22:20:18 +0100
Message-ID: <1261084818.27920.878.camel@laptop>
References: <bug-14794-10286@http.bugzilla.kernel.org/>
	 <20091216154713.f082e7cf.akpm@linux-foundation.org>
	 <4B2A9A40.90203@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37345 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765355AbZLQVVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 16:21:16 -0500
In-Reply-To: <4B2A9A40.90203@freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-12-17 at 21:53 +0100, N=C3=A9meth M=C3=A1rton wrote:
>=20
> I bisected the problem, see
> http://bugzilla.kernel.org/show_bug.cgi?id=3D14794
> for details. Any idea what is the relation between this problem and
> the found
> patch?


If you take 32 and revert just that one patch it works again?

