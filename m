From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 11:40:01 -0700
Message-ID: <46436701.7030906@hp.com>
References: <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com>	<46435412.50800@hp.com>	<464360D6.4080402@hp.com> <46436274.4060804@hp.com> <4643654F.5060207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:43980 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbXEJSkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 14:40:03 -0400
In-Reply-To: <4643654F.5060207@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Not sure if DCCP might fall into this category as well...
> 
> I think the idea of this patch is gather some number of these small packets and
> shove them at the driver in one go instead of each small packet at a time.

This reminds me... (rick starts waxing rhapshodic about old HP-UX behviour :)

The HP-UX drivers have a "packet train" mode whereby IP will give them all the 
fragments of an IP datagram in one shot.  The idea was that the driver would 
take all of them, or none of them.  This was to deal with issues around filling 
a driver's transmit queue with some of the fragments and then dropping the 
others, thus transmitting IP datagrams which had no hope of being reassembled 
into anything other than frankengrams.

rick jones
