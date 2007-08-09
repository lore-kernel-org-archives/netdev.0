From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in IPoIB
Date: Wed, 8 Aug 2007 17:06:41 -0700
Message-ID: <OF5F233CB9.3A75A58F-ON87257332.00003442-88257332.00006C59@us.ibm.com>
References: <20070808134247.GA9942@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, krkumar2@in.ibm.com,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@linux.vnet.ibm.com,
	tgraf@suug.ch, Venkata Jagana <jagana@us.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:35029 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762687AbXHIAG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 20:06:58 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7906wML011190
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 20:06:58 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7906vVK252056
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 18:06:57 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7906tMc002413
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 18:06:57 -0600
In-Reply-To: <20070808134247.GA9942@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Herbert,

> > Not because I think it obviates your work, but rather because I'm
> > curious, could you test a TSO-in-hardware driver converted to
> > batching and see how TSO alone compares to batching for a pure
> > TCP workload?
> 
> You could even lower the bar by disabling TSO and enabling
> software GSO.

We had a discuss before. GSO doesn't benefit device which has no HW 
checksum (like IPoIB) by inducing an extra copy. And GSO benefits one 
stream, batching benefits multiple streams.

Thanks
Shirley
