From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Fri, 22 Jun 2007 18:04:13 -0700
Message-ID: <OF0D7F9D29.61F86942-ON88257303.0005AD2A-88257303.0005D48C@us.ibm.com>
References: <c6d9bea0706221626h434d17d0l6dc3a6a513601546@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: "C. Scott Ananian" <cscott@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:35889 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744AbXFWBER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 21:04:17 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5N14HPO005694
	for <netdev@vger.kernel.org>; Fri, 22 Jun 2007 21:04:17 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5N14HFG240286
	for <netdev@vger.kernel.org>; Fri, 22 Jun 2007 19:04:17 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5N14Hgu006528
	for <netdev@vger.kernel.org>; Fri, 22 Jun 2007 19:04:17 -0600
In-Reply-To: <c6d9bea0706221626h434d17d0l6dc3a6a513601546@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Scott,
        Why not make the application that writes resolv.conf
also listen on a raw ICMPv6 socket? I don't believe you'd need
any kernel changes, then, and it seems pretty simple and
straightforward.

                                        +-DLS

