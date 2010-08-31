From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [RFC][PATCH] QoS TBF and latency configuration misbehavior
Date: Wed, 1 Sep 2010 02:34:02 +0400
Message-ID: <20100831223402.GA7101@ms2.inr.ac.ru>
References: <AANLkTik4Mrzjfk_-u7Qg-B9Q-4tn_seqkkgmwnqQ8FOq@mail.gmail.com> <20100831210101.3c059a91@leibniz> <4C7D5EBD.103@gmail.com> <AANLkTikMJ2rtSNsBeaVTsVtw1ZmKpLjjyeYL=c+AgoFZ@mail.gmail.com> <20100831214808.GA32141@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
To: Dan Kruchinin <dkruchinin@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:58932 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753129Ab0HaWeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 18:34:19 -0400
Content-Disposition: inline
In-Reply-To: <20100831214808.GA32141@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Hmm. Seems, you are right and I was wrong all these years.
Somehow, I did wrong calculation once and this rustied to the brains.
After some thinking the calulation is obviously wrong: no matter what,
in steady state tbf queue is processed with rate R. What a stupid mistake... :-)

Please, also think how to fix the second part of calculation which deals
with peak rate. IMHO (for now :-)) it does not even contribute to latency
and should be deleted.

To Jarek: about the scripts. I do not think something will be broken
by fixing this error. Eventually, if someone used "latency", he meant
something about real latency. And even if the value was generated
using the same wrong logic as tc did, using correct formula would just
increase limit setting.

Alexey
