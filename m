From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 1/10 REV5] [Doc] HOWTO Documentation for batching
Date: Mon, 17 Sep 2007 09:40:36 +0530
Message-ID: <OF47B92F3A.6C42637F-ON65257359.0016D45D-65257359.0016F1B4@in.ibm.com>
References: <20070914113709.80baba4d.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP06.au.ibm.com ([202.81.18.175]:48564 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbXIQEJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 00:09:16 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8H491gi014955
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 14:09:01 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8H4CZI1261304
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 14:12:35 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8H48hWi017474
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 14:08:45 +1000
In-Reply-To: <20070914113709.80baba4d.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Randy,

Randy Dunlap <randy.dunlap@oracle.com> wrote on 09/15/2007 12:07:09 AM:

> > +   To fix this problem, error cases where driver xmit gets called with
a
> > +   skb must code as follows:
> > +      1. If driver xmit cannot get tx lock, return NETDEV_TX_LOCKED
> > +         as usual. This allows qdisc to requeue the skb.
> > +      2. If driver xmit got the lock but failed to send the skb, it
> > +         should return NETDEV_TX_BUSY but before that it should have
> > +         queue'd the skb to the batch list. In this case, the qdisc
>
>                    queued
>
> > +         does not requeue the skb.

Since this was a new section that I added to the documentation, this error
creeped up. Thanks for catching it, and review comments/ack-off :)

thanks,

- KK

