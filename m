From: Jean-Daniel Pauget <jd@disjunkt.com>
Subject: Re: intermittant petabyte usage reported with broadcom nic
Date: Tue, 17 Apr 2007 14:01:48 +0200
Message-ID: <20070417120148.GB5510@disjunkt.com>
References: <20070402014319.GA8345@zip.com.au> <20070402001300.3b66007d.akpm@linux-foundation.org> <20070402074108.GB8345@zip.com.au> <1176596401.5847.7.camel@dell> <1176750651.6217.3.camel@dell> <20070416234348.GF8345@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: CaT <cat@zip.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.17]:63316 "EHLO smtp19.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658AbXDQMJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 08:09:09 -0400
Content-Disposition: inline
In-Reply-To: <20070416234348.GF8345@zip.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2007 at 09:43:48AM +1000, CaT wrote:
> On Mon, Apr 16, 2007 at 12:10:51PM -0700, Michael Chan wrote:
> > On Sat, 2007-04-14 at 17:20 -0700, Michael Chan wrote:
> >=20
> > Here's the debug patch for x86 only that will change the statistics
> > memory block to read-only.  If the kernel is corrupting it, you sho=
uld
> > get a page fault that will crash the system.  If you continue to se=
e
> > bogus counters, it is definitely a firmware or hardware problem.  P=
lease
> > try it and let me know.  Thanks.
[.../...]
> Perhaps Jean-Daniel, who is also experiencing this problem and seemin=
gly
> more frequently then I, has a box that he could run your patch on. I
> think we both run pretty-much the same hardware (Dell [12]950s).
    Dell 1950/2950 indeed...

    if there is any way to catch that writing without crashing the syst=
em=20
    (even to the price of some slowness) I can test it. if not, I can't=
=20
    because all my available targets are remote administrated and invol=
ved=20
    with production processes.
    if luckilly one of them gets free, I'll to apply the latest patch y=
ou'd=20
    provide me. I may also try it one day I'm close to those machines, =
so=20
    keep me in the list of up to date patches.

--=20
    Jean-Daniel Pauget

    T=E9l: +33 (0)2 33 17 20 16
    2, rue Andr=E9 PELCA
    50580 Denneville-Plage
    France

