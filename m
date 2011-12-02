From: Jesse Gross <jesse@nicira.com>
Subject: Re: Integration of Open vSwitch
Date: Fri, 2 Dec 2011 15:08:08 -0800
Message-ID: <CAEP_g=9B-5LT=bm45s9yQzEK-YFB1QWVpHxHpnLdQ+W2BZDf1g@mail.gmail.com>
References: <CAEP_g=-g5g0Z30gYBDAZ8s7ACCZSy5MLJpPDxQmmc8m1wbk3tg@mail.gmail.com>
 <20111130070011.GA32630@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jhs@mojatatu.com, netdev <netdev@vger.kernel.org>,
	dev@openvswitch.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Chris Wright <chrisw@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63787 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248Ab1LBXI2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 18:08:28 -0500
Received: by iage36 with SMTP id e36so4847875iag.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 15:08:28 -0800 (PST)
In-Reply-To: <20111130070011.GA32630@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 11:00 PM, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> The other factor I considered is scalability. =C2=A0The OVS code as i=
s
> is not really friendly to SMP/NUMA scalability (but as Eric pointed,
> neither is the classifier/action layer). =C2=A0However, if this were =
to
> become a problem in future I'm sure we could extend either the
> interface as is (e.g., deploying multiqueue netlink sockets), or
> migrate to something else.

I agree that adding new flows is a weakness of the OVS model
(obviously it was a trade off) that has some room to be improved.
But, as you say, that's more of a long-term project that I think can
be done incrementally over time.

> So I don't really have any objections to this going into the tree.

Great, thanks for reviewing.
