From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] Fix panic in ip6_pol_route
Date: Wed, 6 Apr 2011 13:40:57 +0530
Message-ID: <OFCD49CDC4.C2B9408D-ON6525786A.002C2B92-6525786A.002CBDC6@in.ibm.com>
References: <20110406064504.30691.36599.sendpatchset@krkumar2.in.ibm.com> <20110406.004043.193732725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:34758 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087Ab1DFINX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 04:13:23 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp09.in.ibm.com (8.14.4/8.13.1) with ESMTP id p367CKgL032737
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2011 12:42:20 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p368DKu82687216
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2011 13:43:20 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p368DL6G030165
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2011 13:43:21 +0530
In-Reply-To: <20110406.004043.193732725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 04/06/2011 01:10:43 PM:

> > The fix is to not update ip6_null_entry for a vlan device. Please
> > review.
>
> This is just rediculious.
>
> Configuring a vlan on loopback is stupid.
>
> Having IFF_LOOPBACK be set on a loopback device is even more
> stupid.
>
> So fix one of those two things, otherwise we'll just add a million
> tests over time to this conditional.

We had asked the test team for the reason for this test case:

"I suspect that the use of the loopback, is simply due to some of
our images being very limited and the automated test needed an
interface that it could assume would always exist"

Is it better to disallow configuring vlan on lo?

thanks,

- KK

