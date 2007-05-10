From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 11:07:03 -0700
Message-ID: <1178820423.17393.3.camel@w-sridhar2.beaverton.ibm.com>
References: <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com>
	 <46435412.50800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:41031 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756923AbXEJSHG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 14:07:06 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4AI76eA005929
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 14:07:06 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4AI76wk447252
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 14:07:06 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4AI75dW021265
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 14:07:05 -0400
In-Reply-To: <46435412.50800@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-05-10 at 10:19 -0700, Rick Jones wrote:
> > It is the reverse - GSO will segment one super-packet just before calling
> > the driver so that the stack is traversed only once. In my case, I am
> > trying to send out multiple skbs, possibly small packets, in one shot.
> > GSO will not help for small packets.
> 
> If there are small packets that implies small sends, which suggests that they 
> would be coalesced either implicitly by the Nagle algorithm or explicitly with 
> TCP_CORK no?

small packets belonging to the same connection could be coalesced by
TCP, but this may help the case where multiple parallel connections are
sending small packets.

Thanks
Sridhar

