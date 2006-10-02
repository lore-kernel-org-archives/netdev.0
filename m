From: Ismail Donmez <ismail@pardus.org.tr>
Subject: Re: [PATCH] Revert [NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE
Date: Mon, 2 Oct 2006 16:49:38 +0300
Message-ID: <200610021649.39580.ismail@pardus.org.tr>
References: <20061002102447.GA2936@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: axboe@suse.de, Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:43992 "EHLO uludag.org.tr")
	by vger.kernel.org with ESMTP id S932339AbWJBNtR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 09:49:17 -0400
To: Jarek Poplawski <jarkao2@o2.pl>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <20061002102447.GA2936@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

02 Eki 2006 Pts 13:24 tarihinde, Jarek Poplawski =C5=9Funlar=C4=B1 yazm=
=C4=B1=C5=9Ft=C4=B1:=20
> On 30-09-2006 21:23, Ismail Donmez wrote:
> > Hi,
> >
> > With commit 10fd48f2376db52f08bf0420d2c4f580e39269e1 [1] ,  RB_EMPT=
Y_NODE
> > changed behaviour so it returns false when the node is empty as exp=
ected.
>
> ...
>
> > -	if (!RB_EMPTY_NODE(rb)) {
> > +	if (RB_EMPTY_NODE(rb)) {
>
> Maybe you have some kind of agreement with Jens Axboe but I
> can't understand current way of kernel cooperation:
> he changes some global behavior to the opposite and fixes
> his code in three places but can't fix it in the fourth place
> where it's used? Isn't it both trivial and automatic kind
> of patch?

I don't know if Jens will going to fix other occurrences but the sch_ht=
b.c fix=20
was recent and Jens'  commit got my attention hence the patch.

Regards,
ismail

