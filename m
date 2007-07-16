From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH]: Can not set the IPV6_PKTINFO option
Date: Mon, 16 Jul 2007 14:38:02 +0100
Message-ID: <200707161438.02572@strip-the-willow>
References: <200707161341.23419@strip-the-willow> <20070716.215605.106156812.yoshfuji@linux-ipv6.org> <20070716.220730.18710682.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki /
	 =?iso-2022-jp?q?=1B=24B5HF=231QL=40=1B=28B?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:63802 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757968AbXGPNkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 09:40:13 -0400
In-Reply-To: <20070716.220730.18710682.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting YOSHIFUJI Hideaki / 吉藤英明:
|  Current IPV6_PKTINFO is not equal to IPV6_RECVPKTINFO
|  but a sticky option to set source address / interface
|  for outgoing packet.
Thanks for the update, but there is no `current' IPV6_PKTINFO - set/getsockopt()
on this will result in ENOPROTOOPT.

Manpage date says 1999-06-29 but in fact manpages are from up-to-date lenny/sid.
