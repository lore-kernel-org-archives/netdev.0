From: Bob Beers <bob.beers@gmail.com>
Subject: Re: wanPMC-CxT1E1
Date: Mon, 2 Nov 2009 16:39:22 -0500
Message-ID: <4f6ba3b0911021339v20d7692fm52bcd5208002d6e4@mail.gmail.com>
References: <4f6ba3b0910261322j273c977fm356506c46f095832@mail.gmail.com>
	 <20091026204144.GA28436@kroah.com>
	 <4f6ba3b0910271048n10ff37fek9af191b133892e1e@mail.gmail.com>
	 <m3d4454phz.fsf@intrepid.localdomain>
	 <4f6ba3b0911021241gb6d9684ga76228013e0f5f14@mail.gmail.com>
	 <20091102205911.GA23443@kroah.com>
	 <4f6ba3b0911021316v16ff7431s4dfa939743541df6@mail.gmail.com>
	 <4f6ba3b0911021335k3054da38x56fe72ac7ea8781c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Krzysztof Halasa <khc@pm.waw.pl>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f228.google.com ([209.85.219.228]:40935 "EHLO
	mail-ew0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756697AbZKBVjS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 16:39:18 -0500
Received: by ewy28 with SMTP id 28so5335902ewy.18
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 13:39:22 -0800 (PST)
In-Reply-To: <4f6ba3b0911021335k3054da38x56fe72ac7ea8781c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 2, 2009 at 4:35 PM, Bob Beers <bob.beers@gmail.com> wrote:

> I should be able to fix those things an generate another patch file,
> =A0but my git skills are very weak, so I guess you have the options:
> =A0fix it up by hand, or teach me a little more git, so I can submit
> =A0a better patch.

Here is patch on top of previous patch to fix the two mistakes:

diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index ebc96c7..19d14bc 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -29,7 +29,6 @@ obj-$(CONFIG_DSCC4)             +=3D dscc4.o
 obj-$(CONFIG_X25_ASY)          +=3D x25_asy.o

 obj-$(CONFIG_LANMEDIA)         +=3D lmc/
-obj-$(CONFIG_CXT1E1)           +=3D cxt1e1/

 obj-$(CONFIG_DLCI)             +=3D dlci.o
 obj-$(CONFIG_SDLA)             +=3D sdla.o
diff --git a/drivers/staging/cxt1e1/Makefile b/drivers/staging/cxt1e1/M=
akefile
index edfad71..10020d7 100644
--- a/drivers/staging/cxt1e1/Makefile
+++ b/drivers/staging/cxt1e1/Makefile
@@ -1,4 +1,3 @@
-CONFIG_CXT1E1 =3D m
 obj-$(CONFIG_CXT1E1)   +=3D cxt1e1.o

 EXTRA_CFLAGS +=3D -DSBE_PMCC4_ENABLE

thanks,
--=20
-Bob Beers
