From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 14:20:26 +0530
Message-ID: <OFD1E1285F.980A7DEF-ON652572D8.002FD5E4-652572D8.0030903D@in.ibm.com>
References: <20070511093714.GR2012@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: ak@suse.de, Andi Kleen <andi@firstfloor.org>,
	netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp06.au.ibm.com ([202.81.18.155]:64864 "EHLO
	ausmtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760293AbXEKIvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 04:51:12 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4B8qgkX2056396
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 18:52:42 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4B8sfjx128292
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 18:54:41 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4B8p9Ko011382
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 18:51:09 +1000
In-Reply-To: <20070511093714.GR2012@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andy,

Andi Kleen <ak@suse.de> wrote on 05/11/2007 03:07:14 PM:

> But without it aggregation  on RX is much less useful because the packets
> cannot be kept together after socket demux which happens relatively early
> in the packet processing path.

Then I misunderstood you, my proposal is only for TX. GSO will not help as
it is for large packets to get segmented at the latest point in time to
avoid going through the stack multiple times. My proposal is to link
multiple
packets to send to the device in one shot rather than calling qdisc_restart
multiple times.

> > But for sends, why does same or different connection matter ? There is
> > no aggregating of skbs.
>
> I wasn't talking about sending.
>
> But there actually is :- TSO/GSO.

Sorry to mis-write what I meant : in my proposal there is no aggregating
of skbs so single/multiple connections should not matter.

Thanks,

- KK

