From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: Re: RE: [net-next 2.6 PATCH] net/pcmcia: convert to use
Date: Sun, 21 Feb 2010 15:57:13 +0900 (JST)
Message-ID: <25690823.108851266735433598.ken_kawasaki@spring.nifty.jp>
References: <5083689.85171266728689181.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nfmsa303g.nifmail.jp ([210.131.2.172]:9994 "EHLO
	nfmsa303g.nifmail.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025Ab0BUG5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2010 01:57:38 -0500
Received: from aps515 (aps515 [172.22.128.195]) by nfmsa303g.nifmail.jp with ESMTP id o1L6vDiT010128
	for <netdev@vger.kernel.org>; Sun, 21 Feb 2010 15:57:13 +0900
In-Reply-To: <5083689.85171266728689181.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

sorry, ioaddr is used by PutByte macro.


>
>ioaddr is not used in set_address of xirc2ps_cs.c
>
>
>+static void set_address(struct set_address_info *sa_info, char *addr)
>+{
>+	unsigned int ioaddr = sa_info->ioaddr;             <== HERE
>+	int i;
>+
>+	for (i = 0; i < 6; i++) {
>+		if (sa_info->reg_nr > 15) {
>+			sa_info->reg_nr = 8;
>+			sa_info->page_nr++;
>+			SelectPage(sa_info->page_nr);
>+		}
>+		if (sa_info->mohawk)
>+			PutByte(sa_info->reg_nr++, addr[5 - i]);
>+		else
>+			PutByte(sa_info->reg_nr++, addr[i]);
>+	}
>+}
>+

Ken

