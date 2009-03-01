From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ofa-general] [PATCH 0/26] Reliable Datagram Sockets (RDS), take 2
Date: Sun, 1 Mar 2009 02:50:20 +0100
Message-ID: <20090301015020.GH26292@one.firstfloor.org>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com> <87myc73izx.fsf@basil.nowhere.org> <c0a09e5c0902271753n1a522647g6e7ac5465149c5a4@mail.gmail.com> <20090228055608.GB26292@one.firstfloor.org> <c0a09e5c0902281244u356acbecn98f37ac3abd5ebc0@mail.gmail.com> <20090228223653.GD26292@one.firstfloor.org> <c0a09e5c0902281658v48084cd8w8f95871395020e20@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Andy Grover <andy.grover@oracle.com>, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, general@lists.openfabrics.org
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55444 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbZCABbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 20:31:52 -0500
Content-Disposition: inline
In-Reply-To: <c0a09e5c0902281658v48084cd8w8f95871395020e20@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Higher load -> more time before a process runs -> rcvbuf overfills ->

How can the rcvbuf overfill if the sender doesn't run?

> ACKs dropped -> timeouts -> more retransmissions -> even higher load.
> 
> Things are fine until they hit a point where everything goes to hell.

-Andi
