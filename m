From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH net-next] tipc: tipc_link_is_active() can be static
Date: Mon, 26 Oct 2015 09:13:22 +0800
Message-ID: <20151026011322.GA26877@wfg-t540p.sh.intel.com>
References: <201510242340.mc7bt8l1%fengguang.wu@intel.com>
 <20151024151100.GA46525@lkp-hsx03>
 <20151025.063318.1572658873317450844.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36906 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430AbbJZBNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Oct 2015 21:13:31 -0400
Content-Disposition: inline
In-Reply-To: <20151025.063318.1572658873317450844.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 25, 2015 at 06:33:18AM -0700, David Miller wrote:
> From: kbuild test robot <fengguang.wu@intel.com>
> Date: Sat, 24 Oct 2015 23:11:00 +0800
>=20
> > TO: "David S. Miller" <davem@davemloft.net>
> > CC: netdev@vger.kernel.org
> > CC: Jon Maloy <jon.maloy@ericsson.com>
> > CC: Ying Xue <ying.xue@windriver.com>
> > CC: tipc-discussion@lists.sourceforge.net
> > CC: linux-kernel@vger.kernel.org
> >=20
> >=20
> > Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
>=20
> Why doesn't the kbuild robot run on it's own changes? :-/

It does, however it detects only build failures (which indicates a
false sparse warning) to avoid sending bad make-it-static patch
and the false warning.

The build warning looks easier to be discovered and fixed in the
larger loop of

        apply patch =3D> git push =3D> 0day build test

>   CC [M]  net/tipc/link.o
> net/tipc/link.c:176:12: warning: =E2=80=98tipc_link_is_active=E2=80=99=
 defined but not used [-Wunused-function]

If the robot detected the above warning, it'll still need to send the
report out. Otherwise we lose a chance to notice tipc_link_is_active()
is not used.

However it may be valuable to include possible new warnings inside
the patch changelog, so that maintainers can immediately see the
consequences of applying the patch.

Thanks,
=46engguang
