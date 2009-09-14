From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: Fwd: [RFC v3] net: Introduce recvmmsg socket syscall
Date: Mon, 14 Sep 2009 20:09:02 -0300
Message-ID: <20090914230902.GC22743@ghostprotocols.net>
References: <9b2db90b0908060014r6a1763e8t1b3ee9310e012c25@mail.gmail.com> <9b2db90b0908060015v45d31060me94cf436f4a25e42@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@vger.kernel.org>
To: Nir Tzachar <nir.tzachar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757469AbZINXJG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 19:09:06 -0400
Received: from int-mx03.intmail.prod.int.phx2.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n8EN99T3022282
	for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 19:09:09 -0400
Received: from doppio.ghostprotocols.net (vpn-12-60.rdu.redhat.com [10.11.12.60])
	by int-mx03.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n8EN94aC025668
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 19:09:08 -0400
Content-Disposition: inline
In-Reply-To: <9b2db90b0908060015v45d31060me94cf436f4a25e42@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Aug 06, 2009 at 10:15:26AM +0300, Nir Tzachar escreveu:
> Hello.
> 
> Is there anything new with this patch? What are the plans for merging
> it upstream?

I'm doing perf runs using a test app using recvmsg, then with the first
patch, that introduces recvmmsg, then with the second, that locks the
series of unlocked_recvmmsg calls just once, will try to get this posted
here soon.

I'd really appreciate if the people interested in this could try it and
post numbers too, to get this ball rolling again.

As for getting it upstream, well, posting numbers here would definetely
help with that :-)

- Arnaldo

