From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH RFC] gianfar: Do not call skb recycling with disabled IRQs
Date: Thu, 5 Nov 2009 23:23:23 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B950715@zin33exm22.fsl.freescale.net>
References: <20091104225711.GA30844@oksana.dev.rtsoft.ru> <E1N62ti-0003iS-K2@jdl.com> <20091105142028.GB17171@oksana.dev.rtsoft.ru> <E1N63WM-0003xK-PN@jdl.com> <E1N64UY-00049g-Hb@jdl.com> <20091105165738.GA31923@oksana.dev.rtsoft.ru> <9F4C7D19E8361D4C94921B95BE08B81B950713@zin33exm22.fsl.freescale.net> <E1N66Jp-0004Y0-8Q@jdl.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <avorontsov@ru.mvista.com>, <linuxppc-dev@ozlabs.org>,
	"Jason Wessel" <jason.wessel@windriver.com>,
	"Fleming Andy-AFLEMING" <afleming@freescale.com>,
	"David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Lennert Buytenhek" <buytenh@wantstofly.org>,
	"Stephen Hemminger" <shemminger@vyatta.com>
To: "Jon Loeliger" <jdl@jdl.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:61711 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757766AbZKERxY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 12:53:24 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nA5HrTGq011687
	for <netdev@vger.kernel.org>; Thu, 5 Nov 2009 10:53:29 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id nA5HvHvW029037
	for <netdev@vger.kernel.org>; Thu, 5 Nov 2009 11:57:19 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <E1N66Jp-0004Y0-8Q@jdl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
>
>Similar but different question:  What version is this patch based upon?
>I can't find:
>
>    > >index 197b358..a0ae604 100644
>
>My search of 2.6.31 up through current linux head 
>(v2.6.32-rc6-26-g91d3f9b) and benh's current head 
>(94a8d5caba74211ec76dac80fc6e2d5c391530df) do not have a 
>version of this code with separate txqueues.
>
>I confess I'm not too familiar with the history here, so I 
>don't know if that feature is in flux, or came, or went, or what.
>
>That boils down to:  I can't directly apply your patch, but I 
>could hand-fudge its intent, but only on a single tx queue variant.
>

You might want to get the code base from the top of davem/net-next-2.6
tree

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git

The multi queue is a feature available in etsec2.0 version. On older
versions you might want to 
work in a single queue mode itself.


--

Thanks
Sandeep
