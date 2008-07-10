From: =?ISO-8859-1?Q?Dan_No=E9?= <dnoe@limebrokerage.com>
Subject: Detecting TCP loss on the receiving side?
Date: Thu, 10 Jul 2008 15:44:12 -0400
Message-ID: <4876668C.8040108@limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.limebrokerage.com ([64.111.220.126]:54600 "EHLO
	infra1-jc.limebrokerage.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759500AbYGJTwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 15:52:19 -0400
Received: from [10.12.20.176] (unknown [10.12.20.176])
	by infra1-jc.limebrokerage.com (Postfix) with ESMTP id 194CA17734A
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 15:44:13 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're trying to troubleshoot some problems and we'd like to use the=20
struct tcp_info method to gain some information and attempt to detect=20
TCP loss events on the receiving side of a TCP stream.  The problem is=20
struct tcp_info is not well documented and my attempts to trace it seem=
=20
to reveal that most of the statistics are relevant to the sending side=20
of a TCP connection.

Are there any fields (or any other way) to easily detect loss events?=20
We're mostly concerned with detecting when TCP loss or reordering delay=
s=20
things resulting in additional latency.

Thanks much,
Dan

--=20
Dan No=E9
Software Engineer
Lime Brokerage LLC
781-370-2518
