From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: Raise initial congestion window size / speedup slow  =?UTF-8?Q?start=3F?=
Date: Fri, 16 Jul 2010 11:03:18 +0200
Message-ID: <7065ab9e99967e429c20028f4426e2ff@localhost>
References: <4C3E0684.5060409@wildgooses.com> <4C3E1B54.40604@hp.com>
 <20100714203919.GD6682@nuttenaction>
 <20100714.145547.102555471.davem@davemloft.net>
 <20100714221301.GI6682@nuttenaction>
 <20100714234917.924f420d.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <rick.jones2@hp.com>,
	<lists@wildgooses.com>, <davidsen@tmr.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:44014 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S936026Ab0GPJDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 05:03:20 -0400
In-Reply-To: <20100714234917.924f420d.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 14 Jul 2010 23:49:17 -0400, Bill Fink wrote:



> A long, long time ago, I suggested a Path BW Discovery mechanism

> to the IETF, analogous to the Path MTU Discovery mechanism, but

> it didn't get any traction.  Such information could be extremely

> useful to TCP endpoints, to determine a maximum window size to

> use, to effectively rate limit a much stronger sender from

> overpowering a much weaker receiver (for example 10-GigE -> GigE),

> resulting in abominable performance across large RTT paths

> (as low as 12 Mbps), even in the absence of any real network

> contention.



Much weaker middlebox? The windowing mechanism should be sufficient to

avoid endpoints from over-commiting.



Anyway, your proposed draft (I didn't searched for it) sound like a

mechanism similar to RFC 4782: Quick-Start for TCP and IP.





   This document specifies an optional Quick-Start mechanism for

   transport protocols, in cooperation with routers, to determine an

   allowed sending rate at the start and, at times, in the middle of a

   data transfer (e.g., after an idle period).  While Quick-Start is

   designed to be used by a range of transport protocols, in this

   document we only specify its use with TCP.  Quick-Start is designed

   to allow connections to use higher sending rates when there is

   significant unused bandwidth along the path, and the sender and all

   of the routers along the path approve the Quick-Start Request.





Cheers, Hagen
