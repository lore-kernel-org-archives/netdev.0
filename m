From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: release dst entry in dev_hard_start_xmit()
Date: Tue, 12 May 2009 21:27:48 +0200
Message-ID: <20090512192748.GA2757@ami.dom.local>
References: <49C380A6.4000904@cosmosbay.com> <4A092F59.7020900@cosmosbay.com> <4A093178.9020105@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:62861 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbZELT2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 15:28:11 -0400
Received: by fxm2 with SMTP id 2so184583fxm.37
        for <netdev@vger.kernel.org>; Tue, 12 May 2009 12:28:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A093178.9020105@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2009 at 10:21:12AM +0200, Eric Dumazet wrote:
> Eric Dumazet a =E9crit :
=2E..
> > List of devices that must clear this flag is :
> >=20
> > - loopback device, because it calls netif_rx() and quoting Patrick =
:
> >     "ip_route_input() doesn't accept loopback addresses, so loopbac=
k packets
> >      already need to have a dst_entry attached."
> > - appletalk/ipddp.c : needs skb->dst in its xmit function
> >=20
> > - And all devices that call again dev_queue_xmit() from their xmit =
function
> > (as some classifiers need skb->dst) : bonding, macvlan, eql, ifb, h=
dlc_fr

Why not vlan (and/or maybe others in net/ using dev_queue_xmit)?

Jarek P.
