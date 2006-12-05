From: Brice Goglin <brice@myri.com>
Subject: generic LRO in the net core stack?
Date: Tue, 05 Dec 2006 18:51:25 +0100
Message-ID: <4575B19D.3010205@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:59454 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S968527AbWLERvp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 12:51:45 -0500
To: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

About 2 month ago, I sent a patchset to implement software LRO in
myri10ge. People replied that it might be time to implement something
generic in the net core stack instead since it was the second driver to
do so. We completely agree with this. But, I haven't heard back from
this idea since then, so I was wondering whether somebody is actually
working on it.

If not, I'd like to get our LRO code merged anyway since our driver have
been missing this important feature for a very long time already. We
would drop it later when something generic will be available.

FYI, our myri10ge LRO patch is not intrusive in the driver. It would be
very easy to revert since it only adds lines but does not modify or
remove any single one (see
http://www.mail-archive.com/netdev@vger.kernel.org/msg23133.html).

thanks,
Brice

