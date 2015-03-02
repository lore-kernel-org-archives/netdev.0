From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Subject: RE: [PATCH net-next 0/8] Basic MPLS support
Date: Sun, 1 Mar 2015 16:05:49 -0800
Message-ID: <96cd5ea110617310654d828231f19fd4@mail.gmail.com>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>	<20150227.162131.431559184124647735.davem@davemloft.net>
 <87mw3yg8da.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
	stephen@networkplumber.org, santiago@crfreenet.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:41431 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbbCBAFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 19:05:38 -0500
Received: by widex7 with SMTP id ex7so11179476wid.0
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 16:05:37 -0800 (PST)
In-Reply-To: <87mw3yg8da.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>There is also my experience in router contexts that says arp or neighbour
>discovery is usually the last thing to know (short of gratuitious arps)
that a
>neighbour has failed.  So some other protocol is needed to detect
failure.

Definitely a longer discussion is needed here for the router/switch use
case. Our current position on this (not unique) is to let the protocol
manager which handles the neighbor state machine manage the need or lack
thereof of the GARP's.

This also came up in the L3 offload/switchdev side of the discussion,
where the need maybe more pronounced even.

This has led to mechanisms like BFD to exist which in my opinion causes
more problems than it solves. But sounds like some sunlight on mechanisms
that can be used here may have far reaching benefits.
