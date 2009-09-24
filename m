From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: question on raw sockets and source IP address validation
Date: Thu, 24 Sep 2009 13:37:43 -0600
Message-ID: <4ABBCA87.2040002@nortel.com>
References: <4ABBB223.8090700@nortel.com> <20090924192651.GC19787@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:51384 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754588AbZIXTji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 15:39:38 -0400
In-Reply-To: <20090924192651.GC19787@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/24/2009 01:26 PM, Neil Horman wrote:

> That said, its not doing source validation, your socket is actually doing a
> route lookup on the flow from your specified source address to your destination
> address.  So you should be able to fool the socket into doing the lookup by
> adding a route to your routing table from your source address to your
> destination address via the interface that you want to send the frames out of.

Hmm...that's an interesting point.  Worth investigating for sure.

Thanks,

Chris

