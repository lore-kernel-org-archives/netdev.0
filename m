From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/9] net: add support for IPv6 Segment Routing
Date: Mon, 17 Oct 2016 15:09:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0203D50@AcuExch.aculab.com>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'David Lebrun' <david.lebrun@uclouvain.be>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.187]:58373 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754734AbcJQPMt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 11:12:49 -0400
In-Reply-To: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun
> Sent: 17 October 2016 15:42
 
> Segment Routing (SR) is a source routing paradigm, architecturally
> defined in draft-ietf-spring-segment-routing-09 [1]. The IPv6 flavor of
> SR is defined in draft-ietf-6man-segment-routing-header-02 [2].
> 
> The main idea is that an SR-enabled packet contains a list of segments,
> which represent mandatory waypoints. Each waypoint is called a segment
> endpoint. The SR-enabled packet is routed normally (e.g. shortest path)
> between the segment endpoints. A node that inserts an SRH into a packet
> is called an ingress node, and a node that is the last segment endpoint
> is called an egress node.

Is this a new source routing definition?

I thought the original IPv6 definition contained source routing
(probably because someone thought it was a good idea (tm))
but no one implemented it because of the security implications.

You really don't want sending systems using source routing to
get packets across routers (etc) in ways that are contrary to
the packets actual addresses.

	David
