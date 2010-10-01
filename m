From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: problem with flowi structure
Date: Sat, 2 Oct 2010 01:46:55 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1010020146440.26371@obet.zrqbmnf.qr>
References: <AANLkTi=bGsvMqnTSanA73FhDH_DashmXTcA1sddtj0P6@mail.gmail.com> <1284650768.3352.37.camel@edumazet-laptop> <AANLkTimo1AeBS3rpQj0KtZL15Ct-DGTQMBUsL8hrVNOL@mail.gmail.com> <1284652453.3352.38.camel@edumazet-laptop> <AANLkTi=Y7beG4vPDx5eNg-gTN1CVg_G=1+dWwi2Xd2-R@mail.gmail.com>
 <AANLkTim7TeMCG9RQyrrk8WS4+S_y1q06+8FG2-X=1cB-@mail.gmail.com> <AANLkTimpnqNSE21u=2qjb5VGJrn_3_--Bqp4veCNXMPE@mail.gmail.com> <1284714533.3391.53.camel@edumazet-laptop> <AANLkTi=r__RA=5UfNnhsKizDF6OFVYXcSe9KOPx1zW0u@mail.gmail.com> <1284741295.3391.100.camel@edumazet-laptop>
 <AANLkTi=t2=jqu3XCC-3LK7x1_icke168Bqt-kmds6eOt@mail.gmail.com> <1284745887.2235.7.camel@edumazet-laptop> <AANLkTinx_18cVq52tmC0-g0qLYXJ5c_u9aad_rz_p2ND@mail.gmail.com> <1284746879.2235.9.camel@edumazet-laptop>
 <AANLkTi=hXc_ijNgxW+Q6jkRP_T1zjyy2mvKAdTSgeh7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	AIJAZ BAIG <aijazbaig1@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Nicola Padovano <nicola.padovano@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:56342 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754285Ab0JAXq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Oct 2010 19:46:57 -0400
In-Reply-To: <AANLkTi=hXc_ijNgxW+Q6jkRP_T1zjyy2mvKAdTSgeh7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2010-09-17 20:25, Nicola Padovano wrote:
>
>[CODE]
>if (hooknumber == NF_INET_LOCAL_IN) fl.nl_u.ip4_u.saddr = niph->saddr;
>  //niph is the pointer to ip header of the packet to send
>if (hooknumber == NF_INET_FORWARD) fl.nl_u.ip4_u.saddr = 0;
>[/CODE]
>
>so, i don't understand why saddr = 0 when the hooknumber is NF_INET_FORWARD....
>
>this is the real problem.

0 is automatic address selection.
