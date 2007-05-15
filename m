From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Tue, 15 May 2007 14:08:23 -0700
Message-ID: <adaps51pzg8.fsf@cisco.com>
References: <adad517zk2r.fsf@cisco.com> <200705130800.44595.ak@suse.de>
	<adatzuerr47.fsf@cisco.com>
	<20070515.131840.52167955.davem@davemloft.net>
	<adatzudq06l.fsf@cisco.com> <1179265719.25622.40.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David Miller" <davem@davemloft.net>, ak@suse.de,
	krkumar2@in.ibm.com, "netdev" <netdev@vger.kernel.org>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:33721 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757225AbXEOVIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 17:08:43 -0400
In-Reply-To: <1179265719.25622.40.camel@dell> (Michael Chan's message of "Tue, 15 May 2007 14:48:39 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > Well, IPoIB doesn't do netif_wake_queue() until half the device's TX
 > > queue is free, so we should get batching.  However, I'm not sure that
 > > I can count on a fudge factor ensuring that there's enough space to
 > > handle everything skb_gso_segment() gives me -- is there any reliable
 > > way to get an upper bound on how many segments a given gso skb will
 > > use when it's segmented?
 > 
 > Take a look at tg3.c.  I use (gso_segs * 3) as the upper bound.

Thanks for the pointer... I noticed that code, but could you tell me
where the "* 3" comes from?

 - R.
