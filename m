From: Mohammed Shafi <shafi.wireless@gmail.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024
 AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
Date: Tue, 20 Mar 2012 11:49:32 +0530
Message-ID: <CAD2nsn0d-3edYGH8u+v5mhrUZBMsznDNRDkDHE-tErG8uGk84Q@mail.gmail.com>
References: <4F576FD5.2050208@gmail.com>
	<CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com>
	<4F577D9B.7020402@gmail.com>
	<4F579A88.6030503@openwrt.org>
	<4F61F551.5010608@gmail.com>
	<4F639851.5080500@gmail.com>
	<4F674616.8080103@gmail.com>
	<CAD2nsn3xpkGenrK50YmE5D7Odg3sBEek5zKcLZF6MAm69p5RJg@mail.gmail.com>
	<4F674FF5.2060406@gmail.com>
	<4F6751B2.1030809@openwrt.org>
	<4F681B78.9000207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux-wireless <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>, linux-kernel@vger.kernel.org,
	Linux-netdev <netdev@vger.kernel.org>
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:47148 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753997Ab2CTGTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 02:19:33 -0400
In-Reply-To: <4F681B78.9000207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> (gdb) list *ath9k_tx+start+0x284
> No symbol "start" in current context.

hey, pls try l *(ath9k_tx_start+0x284), yesterday i did the same in
the latest wireless testing tree it pointed to line 1929 of xmit.c

sc->tx.seq_no +=0x10;

also did few suspend/resume in my machine, nothing interesting happened

>
> before receiving the email to do the above code with gdb I had cleaned the
> tree out with git clean -fx so rebuilding might have misalighned things(but
> could be wrong)..
>



-- 
thanks,
shafi
