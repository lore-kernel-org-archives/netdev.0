From: jamal <hadi@cyberus.ca>
Subject: Re: tc related lockdep warning.
Date: Mon, 25 Sep 2006 08:47:53 -0400
Message-ID: <1159188473.5301.68.camel@jzny2>
References: <20060925124352.GA1592@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:7915 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750842AbWIYMsC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 08:48:02 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GRpsS-0007Ug-TL
	for netdev@vger.kernel.org; Mon, 25 Sep 2006 08:48:04 -0400
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20060925124352.GA1592@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-25-09 at 14:43 +0200, Jarek Poplawski wrote:

> It's probably 2.6.18 and should change a little now (git4) but
> IMHO main problem stays: it looks tcf_act_police_locate in
> act_police.c was preempted in read_lock (tcf_police_lookup)
> - now the same is possible in tcf_hash_lookup. So maybe
> read_lock_bh will help?
> 

Yes, that looks plausible. Can you try making those changes and see if
the warning is gone?

cheers,
jamal

