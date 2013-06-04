From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] vxlan: convert remote list to list_rcu
Date: Tue, 4 Jun 2013 09:00:31 -0700
Message-ID: <20130604090031.1283b96f@nehalam.linuxnetplumber.net>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>
	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
	<20130530113739.GB10532@casper.infradead.org>
	<20130531091740.70b3e077@nehalam.linuxnetplumber.net>
	<20130602102942.GA21706@zed>
	<20130603112616.3ad018e2@nehalam.linuxnetplumber.net>
	<OFE7269995.C8314337-ON85257B7F.006B4FC1-85257B7F.006F87F8@us.ibm.com>
	<CAF1J0HNDrqAfWSkdsF7UW=EqJ5yv8hN-uGZi+SRa1F2nYMZWxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:57285 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab3FDQAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 12:00:35 -0400
Received: by mail-pb0-f50.google.com with SMTP id wy17so442085pbc.37
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 09:00:35 -0700 (PDT)
In-Reply-To: <CAF1J0HNDrqAfWSkdsF7UW=EqJ5yv8hN-uGZi+SRa1F2nYMZWxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am still not 100% convinced of the use case of providing multiple destinations.
It seems like either a solution for migrating guests, a way to do SPAN, or a weird
form of multicast.

Wouldn't it be better to use something like TC actions for these special cases and
handle it at the IP layer rather than having to add so much complexity into the
VXLAN driver itself.
