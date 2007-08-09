From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in IPoIB
Date: Thu, 9 Aug 2007 11:56:12 +0530
Message-ID: <OF36DAA51A.D6969B74-ON65257332.001CC7F0-65257332.00235BF1@in.ibm.com>
References: <20070808.212727.60561701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: gaagaan@gmail.com, general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:52657 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760565AbXHIG1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 02:27:18 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l796T6Fd1085530
	for <netdev@vger.kernel.org>; Thu, 9 Aug 2007 16:29:06 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l796THeL072578
	for <netdev@vger.kernel.org>; Thu, 9 Aug 2007 16:29:18 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l796PgsY012856
	for <netdev@vger.kernel.org>; Thu, 9 Aug 2007 16:25:44 +1000
In-Reply-To: <20070808.212727.60561701.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote on 08/09/2007 09:57:27 AM:
>
> > Patrick had suggested calling dev_hard_start_xmit() instead of
> > conditionally calling the new API and to remove the new API
> > entirely. The driver determines whether batching is required or
> > not depending on (skb==NULL) or not. Would that approach be fine
> > with this "single interface" goal ?
>
> It is a valid posibility.
>
> Note that this is similar to how we handle TSO, the driver
> sets the feature bit and in its ->hard_start_xmit() it checks
> the SKB for the given offload property.

Great, I will try to get rid of two paths entirely, and see how to
re-arrange the code cleanly.

thanks,

- KK

