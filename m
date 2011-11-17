From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Thu, 17 Nov 2011 15:51:26 +0100
Message-ID: <1321541486.2751.51.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
	 <1320860984.3916.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321541121.3664.270.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63716 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928Ab1KQOva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 09:51:30 -0500
Received: by bke11 with SMTP id 11so2080027bke.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 06:51:29 -0800 (PST)
In-Reply-To: <1321541121.3664.270.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 14:45 +0000, Ian Campbell a =C3=A9crit=
 :

> Am I right that it's not so much a case of fitting into half a page b=
ut
> more like not wasting nearly half a page if you end up requiring a 40=
96
> byte allocation? (This is probably splitting hairs, I'm really just
> curious)

Performance implications are quite high :

Here is what I did to bnx2x driver to reduce the space from 4096 to
2048, and you can see performance results :

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next.git;a=3Dcomm=
it;h=3De52fcb2462ac484e6dd6e68869536609f0216938
