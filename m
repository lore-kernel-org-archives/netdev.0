From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 3/14] nes: connection manager routines
Date: Thu, 09 Aug 2007 16:06:05 -0500
Message-ID: <46BB81BD.2040904@opengridcomputing.com>
References: <200708080050.l780oGxo004694@neteffect.com> <p73d4xyryg2.fsf@bingen.suse.de> <5E701717F2B2ED4EA60F87C8AA57B7CC07443E9D@venom2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, rdreier@cisco.com,
	ewg@lists.openfabrics.org, netdev@vger.kernel.org
To: Glenn Grundstrom <ggrundstrom@NetEffect.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]:41042 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753506AbXHIVGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 17:06:07 -0400
In-Reply-To: <5E701717F2B2ED4EA60F87C8AA57B7CC07443E9D@venom2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Glenn Grundstrom wrote:
> This code is far from a TCP stack.  It's main purpose is to exchange
> RDMA MPA request/response messages that are required by the iWarp specs
> and therefore needed by our hardware.  All RNIC hardware vendors need
> this MPA message exchange, including those already accepted into
> kernel.org.  Do you have an alternative suggestion?
> 

For the record, the existing linux RNICS don't exactly work this way:

Ammasso handles all TCP connection setup and MPA negotiation in HW/FW. 
The connection setup interface between the RNIC and host driver are 
strictly for RDMA connections.

Chelsio has a message based interface to the HW/FW for establishing
TCP connections and exchanging data in streaming mode.  No TCP
processing is done in the driver.

Steve.
