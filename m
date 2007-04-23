From: David Howells <dhowells@redhat.com>
Subject: Re: Getting the new RxRPC patches upstream
Date: Mon, 23 Apr 2007 09:32:56 +0100
Message-ID: <1355.1177317176@redhat.com>
References: <20070420212835.GA863@tv-sign.ru>  <20070420.015838.83621529.davem@davemloft.net> <29341.1176975158@redhat.com> <2969.1176992303@redhat.com> <1101.1177056127@redhat.com> <4713.1177065706@redhat.com> <20070420113805.c4877dc8.akpm@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	containers@lists.osdl.org, hch@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48552 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753917AbXDWIdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 04:33:31 -0400
In-Reply-To: <20070420212835.GA863@tv-sign.ru> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> We only care when del_timer() returns true. In that case, if the timer
> function still runs (possible for single-threaded wqs), it has already
> passed __queue_work().

Why do you assume that?

David
