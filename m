From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] multiqueue changes
Date: Thu, 8 Oct 2009 12:53:25 +0000
Message-ID: <20091008125325.GA9164@ff.dom.local>
References: <4ACD9255.4020008@gmail.com> <20091008090344.GA7409@ff.dom.local> <20091008120039.GA8691@ff.dom.local> <4ACDD762.9080101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:54713 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490AbZJHMyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 08:54:08 -0400
Received: by bwz6 with SMTP id 6so738991bwz.37
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2009 05:53:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4ACDD762.9080101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 08, 2009 at 02:13:22PM +0200, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > On Thu, Oct 08, 2009 at 09:03:44AM +0000, Jarek Poplawski wrote:
> > ...
> >> num_tx_queues. But it seems we should rather use more often
> >> real_num_tx_queue in schedulers code like dumps and maybe more
> >> (like e.g. sch_multiq does).
> >=20
> > ...i.e. probably everywhere between dev_activate and dev_deactivate
> > all qdisc operations could use real_num_tx_queues (including a test
> > like: netif_is_real_multique), unless I miss something.
>=20
> I am not sure David intent was being able to dynamically adjust real_=
num_tx_queue
> between 1 and num_tx_queue.

If so, then it looks like some drivers could misuse this intent.

Thanks for the explanation,
Jarek P.
