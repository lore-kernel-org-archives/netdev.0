From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Thu, 03 Sep 2009 19:56:33 +0200
Message-ID: <4AA00351.4090601@trash.net>
References: <20090902081429.GB4878@ff.dom.local> <4A9E2CC7.1010103@gmail.com> <alpine.DEB.1.10.0909021313160.27987@V090114053VZO-1> <Pine.LNX.4.64.0909031617060.28935@ask.diku.dk> <4A9FD2DC.7070807@trash.net> <Pine.LNX.4.64.0909031911400.3490@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44485 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753911AbZICR4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 13:56:33 -0400
In-Reply-To: <Pine.LNX.4.64.0909031911400.3490@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> 
> On Thu, 3 Sep 2009, Patrick McHardy wrote:
> 
>> The approach I'm currently working on will present multiqueue root
>> qdiscs as children of a dummy classful qdisc. This avoids handle
>> clashes and the need for new identifiers and allows to address each
>> qdisc seperately, similar to how it works with other classful qdiscs:
> 
> I like your approach. Its well suited for the qdiscs :-)
> 
> I especially like the possibility to access each qdisc seperately.  Does
> it then support having seperate qdisc per TX queue?  (I'm toying with
> the idea of transmitting our multicast traffic into/via a seperate TX
> hardware queue, and making a special qdisc for IPTV MPEG2-TS shaping)

Yes, you can attach qdiscs to the classes representing the queues.
At least it should work :) It would probably also be possible to
use TC classifiers for queue selection.

