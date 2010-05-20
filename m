From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: will 2 cpu simultaneously process packets which have same
 hash value on multiqueue nic?
Date: Thu, 20 May 2010 14:46:07 +0300
Message-ID: <1274355967.17395.5.camel@lb-tlvb-eilong.il.broadcom.com>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497F5B7D6@MILEXCH2.ds.jdsu.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jon Zhou" <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2607 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754283Ab0ETLqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 May 2010 07:46:19 -0400
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497F5B7D6@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-05-19 at 22:37 -0700, Jon Zhou wrote:
> will 2 cpu simultaneously  process packets which have same hash value on multiqueue nic?
> 
> let 's take broadcom 57711 bnx2x_main.c as an example:
> 
> #1 packet1->queue=1
> #2 packet2->queue=1
> 
> will cpu1 and cpu2 execute the function " bnx2x_rx_int" in parallel, to receive packet1 & packet2
Both packets will be handled by the same queue and the queue processing
is serialized - so the packets will be handled one after the other.

Regards,
Eilon


