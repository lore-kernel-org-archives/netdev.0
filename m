From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Wed, 2 Sep 2009 13:12:55 -0500 (CDT)
Message-ID: <alpine.DEB.1.10.0909021311560.27987@V090114053VZO-1>
References: <20090902081429.GB4878@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:53668 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750933AbZIBOOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 10:14:21 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1320982C812
	for <netdev@vger.kernel.org>; Wed,  2 Sep 2009 10:16:01 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jfoZClWDH7Ii for <netdev@vger.kernel.org>;
	Wed,  2 Sep 2009 10:16:00 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0BE3E82C817
	for <netdev@vger.kernel.org>; Wed,  2 Sep 2009 10:15:25 -0400 (EDT)
In-Reply-To: <20090902081429.GB4878@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2 Sep 2009, Jarek Poplawski wrote:

> I think, tc should've no problem with displaying summary stats of
> multiqueue qdiscs or even all of them separately, as mentioned by
> Patrick. And, maybe I still miss something, but there should be
> nothing special with tc vs. localhost either.

Ok. Can you come up with a patch? net/sched/sch_api.c can likely be
patches with the loop logic that Eric suggested earlier.
