From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH] net: Add network namespace clone & unshare support.
Date: Fri, 28 Sep 2007 13:56:04 +0200
Message-ID: <46FCEBD4.1060802@fr.ibm.com>
References: <m1tzphrnq5.fsf@ebiederm.dsl.xmission.com> <46FB6F1E.8070105@fr.ibm.com> <m1k5qcjaiu.fsf@ebiederm.dsl.xmission.com> <20070927.124552.69400277.davem@davemloft.net> <m18x6rhfy0.fsf@ebiederm.dsl.xmission.com> <46FCC56D.9050600@fr.ibm.com> <20070928022842.8f408d71.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:42903 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751584AbXI1L4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 07:56:13 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8SBuDsW003524
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 07:56:13 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8SBuDNo545486
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 07:56:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8SBuCCD007461
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 07:56:13 -0400
In-Reply-To: <20070928022842.8f408d71.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Fri, 28 Sep 2007 11:12:13 +0200 Cedric Le Goater <clg@fr.ibm.com> wrote:
> 
>>> Cedric made a good point that we will have conflicts of code
>>> being added to the same place in nsproxy.c and the like.  So
>>> I copied Andrew to give him a heads up.
>> here's a suggestion,
>>
>> we could keep the net namespace unshare patch out of david's tree,
>> let andrew merge and release a new -mm and, then, send the net namespace 
>> unshare patch to andrew. that should keep nsproxy out of the andrew's 
>> merge challenge. But david's tree will miss the unshare part for a while.
> 
> This patch only generates two rejects against the current -mm poop pile.
> That's insignificant.  We don't need to do anything special to merge a
> little patch like this one.

Thanks Andrew.

C.
