From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Provide SYN packet for passive connections
Date: Sun, 11 Mar 2012 21:08:38 -0700
Message-ID: <CA+mtBx_LqwUpe5Df3VPw-L=h-WUjr=fxh86rgNuYnMacNikuOA@mail.gmail.com>
References: <alpine.DEB.2.00.1203111944520.1019@pokey.mtv.corp.google.com>
	<20120311.195542.1995263719633128071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:46487 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715Ab2CLEIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 00:08:39 -0400
Received: by iagz16 with SMTP id z16so6270966iag.19
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2012 21:08:38 -0700 (PDT)
In-Reply-To: <20120311.195542.1995263719633128071.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I dunno, bloating up the socket and the mini-req structure by 8+ bytes
> for what's essentially a very fringe feature?

For inet_connection_sock I believe there are fields that would only be
used for a listeners(e.g. icsk_accept_queue), and fields that would
only be used for a real connection (e.g. icsk_retransmits).  Would it
be worth it to split these into a union?
