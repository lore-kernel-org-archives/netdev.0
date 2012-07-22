From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC] tcp: use seqlock for all cached tcp_metrics
Date: Sun, 22 Jul 2012 23:34:38 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207222314230.2458@ja.ssi.bg>
References: <1342950268-2380-1-git-send-email-ja@ssi.bg> <20120722.123246.864281319907290494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:48455 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752429Ab2GVU1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2012 16:27:09 -0400
In-Reply-To: <20120722.123246.864281319907290494.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 22 Jul 2012, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Sun, 22 Jul 2012 12:44:28 +0300
> 
> > 	The ability to reclaim existing cache entries
> > requires metrics to be accessed with additional seqlock.
> > fastopen_cache tried to provide such locking for its values
> > but there is always the risk to access reclaimed entry.
> 
> I basically claim that accidental use of reclaimed entries
> is completely harmless for everything other than fastopen.
> 
> Therefore I do not advocate adding the new overhead and complexity for
> the non-fastopen cases.  It should be a completely free, lockless, and
> synchornization free cache.  If we read crap metrics, so be it, maybe
> the network dynamics changed to the same amount, and we would never
> know the different.  Therefore, it doesn't really matter if we read
> crap values for these measurements.

	OK, it seems I didn't understand you fully in previous
email. So, I can just send patch (or 2) for the tcpm_stamp and
tcp_tw_remember_stamp problems, now or after 2 weeks?

> Thanks.

Regards

--
Julian Anastasov <ja@ssi.bg>
