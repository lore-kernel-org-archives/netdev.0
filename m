From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] core: Call net_tx_action only if work pending
Date: Wed, 9 May 2007 09:54:56 +0530
Message-ID: <OFCF7BF07C.6144A4C9-ON652572D6.00183AD5-652572D6.00184189@in.ibm.com>
References: <20070508.185952.115910331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp06.au.ibm.com ([202.81.18.155]:32910 "EHLO
	ausmtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117AbXEIEZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:25:58 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l494RTAQ8437830
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 14:27:29 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l494TQn5133282
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 14:29:26 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l494Psbj005008
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 14:25:54 +1000
In-Reply-To: <20070508.185952.115910331.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Agreed :)

- KK

David Miller <davem@davemloft.net> wrote on 05/09/2007 07:29:52 AM:

> From: Krishna Kumar <krkumar2@in.ibm.com>
> Date: Tue, 08 May 2007 13:01:30 +0530
>
> > Optimize call to net_tx_action only if work is pending.
> >
> > Patch against net-2.6.22.git
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
>
> I don't think downing a cpu is done so often as to justify this
> microscopic optimization, do you?

