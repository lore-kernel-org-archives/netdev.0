From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
 from the host TCP port space.
Date: Fri, 17 Aug 2007 14:27:56 -0700 (PDT)
Message-ID: <20070817.142756.65194845.davem@davemloft.net>
References: <1187271791.4685.9.camel@trinity.ogc.int>
	<20070816.141751.115907875.davem@davemloft.net>
	<adaodh6x7js.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@opengridcomputing.com, jeff@garzik.org,
	swise@opengridcomputing.com, mshefty@ichips.intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33195
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758070AbXHQV15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 17:27:57 -0400
In-Reply-To: <adaodh6x7js.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Fri, 17 Aug 2007 12:52:39 -0700

>  > When using RDMA you lose the capability to do packet shaping,
>  > classification, and all the other wonderful networking facilities
>  > you've grown to love and use over the years.
> 
> Same thing with TSO and LRO and who knows what else.

Not true at all.  Full classification and filtering still is usable
with TSO and LRO.
