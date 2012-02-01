From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 1/6] net: pad skb data and shinfo as a whole rather
 than individually
Date: Wed, 01 Feb 2012 11:02:02 +0100
Message-ID: <1328090522.2595.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
	 <1327494434-21566-1-git-send-email-ian.campbell@citrix.com>
	 <1327495879.2425.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1327496953.24561.323.camel@zakaz.uk.xensource.com>
	 <1327497157.2425.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328020528.26983.396.camel@zakaz.uk.xensource.com>
	 <1328021140.2297.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328089187.17444.10.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60998 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286Ab2BAKCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 05:02:07 -0500
Received: by werb13 with SMTP id b13so798932wer.19
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 02:02:05 -0800 (PST)
In-Reply-To: <1328089187.17444.10.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 f=C3=A9vrier 2012 =C3=A0 09:39 +0000, Ian Campbell a =C3=
=A9crit :

> I'll investigate the sending side. The sender is running a 2.6.32 dis=
tro
> kernel. Maybe I need to tweak it somewhat.

Thats strange, even a very old kernel is able to sustain Gigabit line
rate with pktgen. Maybe a problem with a switch and ethernet pauses ?
