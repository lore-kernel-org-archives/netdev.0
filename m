From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC net] neigh: do not modify unlinked entries
Date: Fri, 19 Jun 2015 11:24:24 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1506191115450.4285@ja.home.ssi.bg>
References: <1434484599-5875-1-git-send-email-ja@ssi.bg> <5583C13D.7050904@miraclelinux.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-988862769-1434702266=:4285"
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Ying Xue <ying.xue@windriver.com>, alexei@purestorage.com,
	joern@purestorage.com
To: =?UTF-8?Q?YOSHIFUJI_Hideaki=2F=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:43965 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753740AbbFSIYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2015 04:24:33 -0400
In-Reply-To: <5583C13D.7050904@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-988862769-1434702266=:4285
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Fri, 19 Jun 2015, YOSHIFUJI Hideaki/吉藤英明 wrote:

> Should we always drop the packet here since it is
> already dead, shouldn't we?

	It can be a NETDEV_CHANGEADDR event, eth_header()
will build valid header. It can be some race condition
with neigh_forced_gc and neigh_periodic_work where we can
not fallback to neigh_create. It is not our job to
drop packets, so I preferred to avoid it...

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-988862769-1434702266=:4285--
