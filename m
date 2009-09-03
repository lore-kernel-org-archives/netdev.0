From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Thu, 03 Sep 2009 21:38:54 +0200
Message-ID: <4AA01B4E.9060501@gmail.com>
References: <20090902212708.GC3018@ami.dom.local> <alpine.DEB.1.10.0909031302190.27903@V090114053VZO-1> <20090903193555.GA3138@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40274 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756171AbZICTi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 15:38:59 -0400
In-Reply-To: <20090903193555.GA3138@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Thu, Sep 03, 2009 at 01:03:37PM -0500, Christoph Lameter wrote:
>> On Wed, 2 Sep 2009, Jarek Poplawski wrote:
>>
>>> Btw, Patrick's comments reminded me this is probably not what you w=
ant
>>> in case of non-default qdiscs: the root qdisc like prio will be
>>> repeated for each tx queue with the same stats. I guess you need to=
 do
>>> here an additional query e.g. by comparing dev_queue->qdisc_sleepin=
g
>>> with that of i =3D 0.
>> Hmmm.. Maybe I better leave it to the experts then.
>>
>=20
> This is certainly not what I wanted... The experts missed this proble=
m
> long enough. It might only need to wait a bit for Patrick's changes.

The experts ? Anyway, you can say "the expert", there is only one :)


