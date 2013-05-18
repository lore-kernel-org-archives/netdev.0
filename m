From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net] vxlan: listen on multiple ports
Date: Fri, 17 May 2013 23:59:03 -0400
Message-ID: <OF0A8D9398.8E59B8DA-ON85257B6F.0014B0DC-85257B6F.0015E329@us.ibm.com>
References: <20130516143520.581d1d78@nehalam.linuxnetplumber.net>	<20130517.140655.2182995212892285929.davem@davemloft.net> <CAOaVG15gx4Fqgqwjg5v-k=r4FrVNgTh9EpnnmxGECc5Wv_X=wA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:36789 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751306Ab3ERD7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 May 2013 23:59:12 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Fri, 17 May 2013 23:59:11 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 6B8D76E8039
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 23:59:04 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4I3x7rH275478
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 23:59:07 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4I3x6wK023825
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 21:59:07 -0600
In-Reply-To: <CAOaVG15gx4Fqgqwjg5v-k=r4FrVNgTh9EpnnmxGECc5Wv_X=wA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> wrote on 05/17/2013 
11:05:16 PM:

> then the original commit to add NDA_PORT should be reverted from 3.10
> no point in continuing the half baked idea

I don't think these are linked at all. While being able to specify
multiple listen ports, I agree, is a good idea, being able to specify
alternate remote ports is needed because you can already change the
one per-host port.

With only one listen port per host, if they are different on two hosts,
NDA_PORT in the fdb table is the only way those two hosts can use VXLAN
with each other at all.

It has nothing to do with how many listen ports there are, but just that
the listen port can be different on different hosts.

                                                                +-DLS
