From: "Sanagi, Koki" <sanagi.koki@jp.fujitsu.com>
Subject: RE: [PATCH] skb: add a comment to skb_csum_unnecessary to avoid
 miuse
Date: Wed, 23 Jan 2013 02:32:52 +0000
Message-ID: <F6CB40852BC6EF489E0AA83EFF537F470876B9FD@G01JPEXMBYT04>
References: <50FF2F18.1050408@jp.fujitsu.com>
 <20130122.205346.633138554393148358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:57999 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600Ab3AWCcz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 21:32:55 -0500
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 219BC3EE0B5
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 11:32:54 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 02FF545DD78
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 11:32:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E283B45DD74
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 11:32:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D2BE61DB8038
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 11:32:53 +0900 (JST)
Received: from g01jpexchyt05.g01.fujitsu.local (g01jpexchyt05.g01.fujitsu.local [10.128.194.44])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 879FD1DB802C
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 11:32:53 +0900 (JST)
In-Reply-To: <20130122.205346.633138554393148358.davem@davemloft.net>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> Date: Wed, 23 Jan 2013 09:30:16 +0900
> 
> > Due to its name and appearance, someone thinks this only checks if
> > ip_summed is CHECKSUM_UNNECESARRY.  But actually, this returns true
> > even if ip_summed is CHECKSUM_PARTIAL.  To avoid misuse, this patch a
> > comment which specifies that CHECKSUM_PARTIAL is OK.
> >
> > Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> 
> I'm not applying this, sorry.  It's a one line function and it's not so
> non-obvious that it deserves an 8 line comment.

OK.  I just felt weird that CHECKSUM_* is not bit flag but this function handles
it as if it was bit flag.
