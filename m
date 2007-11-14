From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] PATCH 1/2 [SCHED 2.6.24]: Check subqueue status before calling
 hard_start_xmit
Date: Wed, 14 Nov 2007 13:17:13 +0530
Message-ID: <OFBECB3B91.68D55578-ON65257393.002AB87D-65257393.002AC686@in.ibm.com>
References: <20071113.221439.225154441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([59.145.155.7]:42117 "EHLO
	e28esmtp07.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750955AbXKNHou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 02:44:50 -0500
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id lAE7ie6i016080
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 13:14:40 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAE7idI04419672
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 13:14:39 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id lAE7idGo020150
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 07:44:39 GMT
In-Reply-To: <20071113.221439.225154441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

David Miller <davem@davemloft.net> wrote on 11/14/2007 11:44:39 AM:

> > You could optimize this by getting HARD_TX_LOCK after the check. I
> > assume that netif_stop_subqueue (from another CPU) would always be
> > called by the driver xmit, and that is not possible since we hold
> > the __LINK_STATE_QDISC_RUNNING bit. Does that sound correct?
>
> I don't think this is a critical optimization at this time,
> but something to certainly do along with the surgery
> we'll undoubtedly be doing here in the future :-)

Agree. Will keep in mind for later :)

Thanks,

- KK

