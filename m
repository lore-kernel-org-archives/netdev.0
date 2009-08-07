From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH ver2] Avoid enqueuing skb for default qdiscs
Date: Fri, 7 Aug 2009 08:31:37 +0530
Message-ID: <OF7BAC954C.BF5F5187-ON6525760B.00102708-6525760B.0010A0A6@in.ibm.com>
References: <20090806114421.19208.39374.sendpatchset@localhost.localdomain> <20090806134946.1772dd5a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	Jarek Poplawski <jarkao2@gmail.com>, kaber@trash.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([59.145.155.9]:45525 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756548AbZHGDBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 23:01:50 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id n772wuYX025972
	for <netdev@vger.kernel.org>; Fri, 7 Aug 2009 08:28:56 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7731nCZ2220032
	for <netdev@vger.kernel.org>; Fri, 7 Aug 2009 08:31:49 +0530
Received: from d28av06.in.ibm.com (loopback [127.0.0.1])
	by d28av06.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7734bre002611
	for <netdev@vger.kernel.org>; Fri, 7 Aug 2009 08:34:38 +0530
In-Reply-To: <20090806134946.1772dd5a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Stephen Hemminger <shemminger@vyatta.com> wrote on 08/07/2009 02:19:46 AM:

> > +static inline int qdisc_qlen(struct Qdisc *q)
> > +{
> > +   return q->q.qlen;
> > +}
> > +
>
> Why?
> This kind of oneline accessor decreases the code clarity.

qdisc_qlen() was previously defined in sch_generic.c. I moved it
to the header file so that it could be accessed in dev.c (where
there is no code using q.qlen), so it is not new code.

Thanks,

- KK

