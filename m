From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Thu, 3 Sep 2009 21:54:22 +0200
Message-ID: <20090903195422.GB3138@ami.dom.local>
References: <20090902212708.GC3018@ami.dom.local>
 <alpine.DEB.1.10.0909031302190.27903@V090114053VZO-1>
 <20090903193555.GA3138@ami.dom.local>
 <4AA01B4E.9060501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:44876 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932160AbZICTyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 15:54:47 -0400
Received: by fxm17 with SMTP id 17so211732fxm.37
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2009 12:54:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AA01B4E.9060501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 03, 2009 at 09:38:54PM +0200, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > On Thu, Sep 03, 2009 at 01:03:37PM -0500, Christoph Lameter wrote:
> >> On Wed, 2 Sep 2009, Jarek Poplawski wrote:
> >>
> >>> Btw, Patrick's comments reminded me this is probably not what you=
 want
> >>> in case of non-default qdiscs: the root qdisc like prio will be
> >>> repeated for each tx queue with the same stats. I guess you need =
to do
> >>> here an additional query e.g. by comparing dev_queue->qdisc_sleep=
ing
> >>> with that of i =3D 0.
> >> Hmmm.. Maybe I better leave it to the experts then.
> >>
> >=20
> > This is certainly not what I wanted... The experts missed this prob=
lem
> > long enough. It might only need to wait a bit for Patrick's changes=
=2E
>=20
> The experts ? Anyway, you can say "the expert", there is only one :)

Right! I admire Davem too... ;-)

Jarek P.
