From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH v3] vxlan: Allow setting destination to unicast address.
Date: Tue, 16 Apr 2013 09:04:22 -0400
Message-ID: <OFFC1F809A.A46D5693-ON85257B4F.0045C6CF-85257B4F.0047D03F@us.ibm.com>
References: <87hajcm7ym.wl%atzm@stratosphere.co.jp>	<OF3CF233D4.68C04252-ON85257B4E.006F940A-85257B4E.0072C761@us.ibm.com> <CAF1J0HNo=8CE0mMbWGrS4xqeivaZ8WTMwb=R92UP2rtH_ngLEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Atzm Watanabe <atzm@stratosphere.co.jp>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:35355 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932863Ab3DPNJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 09:09:13 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 16 Apr 2013 07:09:12 -0600
In-Reply-To: <CAF1J0HNo=8CE0mMbWGrS4xqeivaZ8WTMwb=R92UP2rtH_ngLEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 04/16/2013 02:46:36 AM:

> From: Mike Rapoport <mike.rapoport@ravellosystems.com>

> I've just sent an rfc patch that is slightly more generic version of
> Atzm Watanabe work (1). It makes the "default destination" a list of
> destinations rather than a single entry.
> If the approach seems Ok, I can extend it to do "everything an fdb can".

I'd like to see those combined, with the "group" references changed to
"remote_default", "default_dst" or something along those lines to
indicate it is a default fdb entry.

When a new list element is a multicast address, also join the group
for receive side.

Also allow PORT, VNI and IFINDEX attributes, and require nonzero,
valid IFINDEX for multicast destinations.

So, yes, I think your patch is a step in the right direction.

                                                +-DLS
