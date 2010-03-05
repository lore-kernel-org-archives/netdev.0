From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH V3 5/8] sctp: use limited socket backlog
Date: Fri, 05 Mar 2010 14:24:02 +0100
Message-ID: <1267795442.3280.1.camel@edumazet-laptop>
References: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-2-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-3-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-4-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-5-git-send-email-yi.zhu@intel.com>
	 <1267770483.2867.6.camel@edumazet-laptop>
	 <DA586906BA1FFC4384FCFD6429ECE860A4604767@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: "Zhu, Yi" <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:54009 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab0CENYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 08:24:11 -0500
Received: by bwz22 with SMTP id 22so587412bwz.28
        for <netdev@vger.kernel.org>; Fri, 05 Mar 2010 05:24:08 -0800 (PST)
In-Reply-To: <DA586906BA1FFC4384FCFD6429ECE860A4604767@shzsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 mars 2010 =C3=A0 19:05 +0800, Zhu, Yi a =C3=A9crit :

> I don't see how the order is important here. We are under sock_lock=20
> here thus nobody will race with us. IMHO, the comment talks about
> if a packet is queued into the backlog, we need to increase the assoc=
/ep
> reference count. Otherwise the assoc/ep might be disappeared when
> we are about to process it (by sctp_backlog_rcv) sometime later.
>=20

OK then.

Its strange this protocol has to increase a refcount for each queued
frame in its backlog, but this is unrelated to your changes anyway.




