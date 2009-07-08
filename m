From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] [PATCHv6 1/2] net: adding memory barrier to the
	poll and receive callbacks
Date: Wed, 8 Jul 2009 22:06:41 +0200
Message-ID: <20090708200641.GA12750@ami.dom.local>
References: <20090708194726.GA3196@jolsa.lab.eng.brq.redhat.com> <20090708194850.GB3196@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	mathieu.desnoyers@polymtl.ca, mingo@elte.hu,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, htejun@gmail.com,
	oleg@redhat.com, davidel@xmailserver.org, davem@davemloft.net
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:35461 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388AbZGHUHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 16:07:02 -0400
Content-Disposition: inline
In-Reply-To: <20090708194850.GB3196@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 08, 2009 at 09:48:50PM +0200, Jiri Olsa wrote:
> Adding memory barrier after the poll_wait function, paired with
> receive callbacks. Adding fuctions sk_poll_wait and sk_has_sleeper
- receive callbacks. Adding fuctions sk_poll_wait and sk_has_sleeper
+ receive callbacks. Adding fuctions sock_poll_wait and sk_has_sleeper

Did I miss this in v5?!

Sorry ;-)
Jarek P.
