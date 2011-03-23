From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity: fix the WOL bug on 1000M full duplex
 forced mode.
Date: Wed, 23 Mar 2011 12:25:55 -0700 (PDT)
Message-ID: <20110323.122555.232730923.davem@davemloft.net>
References: <20110120145933.GC7291@electric-eye.fr.zoreil.com>
	<20110120.165634.257520752.davem@davemloft.net>
	<AANLkTikoVgwu1SQ_fpTLS3coqOWbMy__9Y9eANYYmkWo@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, DavidLv@viatech.com.cn
To: davidlv.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59288
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756578Ab1CWTZQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 15:25:16 -0400
In-Reply-To: <AANLkTikoVgwu1SQ_fpTLS3coqOWbMy__9Y9eANYYmkWo@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Lv <davidlv.linux@gmail.com>
Date: Wed, 23 Mar 2011 18:07:54 +0800

> Hi, David. I haven't found out this patch code in the mainline of 2.6=
=2E38.
> Could you help me check it?

It's there in Linus's tree, it did not make it into 2.6.38:

commit 2ffa007eaa01cf5fedd6a71f7d43854339a831ee
Author: fran=E7ois romieu <romieu@fr.zoreil.com>
Date:   Thu Jan 20 04:59:33 2011 +0000

    via-velocity: fix the WOL bug on 1000M full duplex forced mode.
   =20
    The VIA velocity card can't be waken up by WOL tool on 1000M full
    duplex forced mode. This patch fixes the bug.
   =20
    Signed-off-by: David Lv <DavidLv@viatech.com.cn>
    Acked-by: Francois Romieu <romieu@fr.zoreil.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

