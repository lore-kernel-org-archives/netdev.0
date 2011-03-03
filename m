From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Thu, 03 Mar 2011 10:07:58 +0100
Message-ID: <1299143278.2983.1.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
	 <20110302020610.GD1005@gandalf.sssup.it>
	 <1299064667.2920.4.camel@edumazet-laptop> <20110302081108.689571d8@nehalam>
	 <1299082728.2920.18.camel@edumazet-laptop>
	 <1299087087.2920.27.camel@edumazet-laptop>
	 <20110303081940.GA29685@gandalf.sssup.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org,
	Paolo Valente <paolo.valente@unimore.it>
To: Fabio Checconi <fchecconi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56339 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755465Ab1CCJID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 04:08:03 -0500
Received: by fxm17 with SMTP id 17so882782fxm.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 01:08:02 -0800 (PST)
In-Reply-To: <20110303081940.GA29685@gandalf.sssup.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 09:19 +0100, Fabio Checconi a =C3=A9crit :

> The same bug you identified in qfq_reset_qdisc() is present also in
> qfq_drop(), both loops need to be corrected...

I dont think so, because in qfq_drop() we exit from qfq_drop() right
after call to qfq_deactivate_class()

But I agree code should be same ;)



