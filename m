From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/3] bql: Byte queue limits
Date: Thu, 28 Apr 2011 05:53:05 -0700
Message-ID: <BANLkTikeGhmyswra_Z38eXMBuZk2seoPwQ@mail.gmail.com>
References: <alpine.DEB.2.00.1104252128290.5895@pokey.mtv.corp.google.com>
	<20110426091620.7c576a98@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:49907 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759375Ab1D1MxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 08:53:08 -0400
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p3SCr7C8007135
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 05:53:07 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by hpaq13.eem.corp.google.com with ESMTP id p3SCqsom026979
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 05:53:05 -0700
Received: by pzk37 with SMTP id 37so2880501pzk.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 05:53:05 -0700 (PDT)
In-Reply-To: <20110426091620.7c576a98@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Although this is implemented as a device attribute, from a layering
> point of view it feels like a queuing strategy. Having two competing
> ways to do something is not always a good idea. Why is this not a
> qdisc parameter or a new qdisc?
>
It's an interesting idea, but I'm not sure that this would fit into
the qdisc model without some major re-architecture.  The qdiscs manage
host side above the device, BQL is another layer that would need to be
added beyond the that which is logically below the leaf qdiscs.

Tom

> --
>
