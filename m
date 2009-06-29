From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] net: adding memory barrier to the poll and receive
	callbacks
Date: Mon, 29 Jun 2009 20:14:42 +0200
Message-ID: <20090629181442.GF2742@ami.dom.local>
References: <20090629140434.GE3845@jolsa.lab.eng.brq.redhat.com> <20090629141445.GF3845@jolsa.lab.eng.brq.redhat.com> <alpine.DEB.1.10.0906290826300.29966@makko.or.mcafeemobile.com> <20090629173217.GC2742@ami.dom.local> <alpine.DEB.1.10.0906291033140.30244@makko.or.mcafeemobile.com> <20090629180431.GE2742@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, oleg@redhat.com, eric.dumazet@gmail.com
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:38188 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757745AbZF2SPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 14:15:16 -0400
Content-Disposition: inline
In-Reply-To: <20090629180431.GE2742@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2009 at 08:04:31PM +0200, Jarek Poplawski wrote:
...
> Btw., maybe I miss something but I guess Oleg proposed something in
> between: inlining __poll_wait(), which would save us 'extra API' and
> compiler doubts. (But I still prefer Jiri's choice. ;-)

After re-reading I guess Oleg didn't proposed anything in between yet.

Sorry,
Jarek P.
