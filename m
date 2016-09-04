From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] qed: Remove OOM messages
Date: Sun, 4 Sep 2016 08:18:09 +0000
Message-ID: <DM5PR11MB17232554E85D036D17C1840B97E70@DM5PR11MB1723.namprd11.prod.outlook.com>
References: <1472838261.6758.74.camel@perches.com>
 <6d6f56d8324237957b19f069357e2aa9e4bcd959.1472836194.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Ariel Elior <Ariel.Elior@qlogic.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0106.outbound.protection.outlook.com ([104.47.40.106]:54428
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752022AbcIDISa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Sep 2016 04:18:30 -0400
In-Reply-To: <6d6f56d8324237957b19f069357e2aa9e4bcd959.1472836194.git.joe@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> These messages are unnecessary as OOM allocation failures already do a
> dump_stack() giving more or less the same information.
>=20
> $ size drivers/net/ethernet/qlogic/qed/built-in.o* (defconfig x86-64)
>    text	   data	    bss	    dec	    hex	filename
>  126849	  27968	  32800	 187617	  2dce1	drivers/net/ethernet/qlogic/qed/b=
uilt-
> in.o.new
>  131506	  27968	  32800	 192274	  2ef12	drivers/net/ethernet/qlogic/qed/b=
uilt-
> in.o.old
>=20
> Miscellanea:
>=20
> o Change allocs to the generally preferred forms where possible.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>

Looking good. Thanks Joe.

Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
