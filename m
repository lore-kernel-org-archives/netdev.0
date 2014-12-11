From: "Hubert Sokolowski" <h.sokolowski@wit.edu.pl>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Thu, 11 Dec 2014 16:51:33 -0000
Message-ID: <ef837b2e2427434f906bedd957c3cc9b.squirrel@poczta.wsisiz.edu.pl>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>
    <20141210.233239.472984361665334371.davem@davemloft.net>
    <548984C0.2040706@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF8
Content-Transfer-Encoding: 8bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Roopa Prabhu" <roopa@cumulusnetworks.com>,
	"Vlad Yasevich" <vyasevic@redhat.com>
To: "Jamal Hadi Salim" <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dervish.wsisiz.edu.pl ([213.135.44.54]:50981 "EHLO
	dervish.wsisiz.edu.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933617AbaLKQvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 11:51:36 -0500
In-Reply-To: <548984C0.2040706@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> It wont work. As pointed out by Roopa in
> the other email dev->uc/mc will not get dumped with this
> change. Vlad will be in a better position to comment.
> CCing Vlad.

Jamal, this will still get dumped unless your driver implements
own dump callback. Can you please exactly tell us what wont work?
Please see my previous post where I added more explanation.

Thanks,
Hubert
