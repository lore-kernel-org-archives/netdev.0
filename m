From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [IPv6] Fix ICMPv6 redirect handling with target multicast address
Date: Tue, 2 Oct 2007 15:41:46 -0700
Message-ID: <OFD478AB10.744D71F8-ON88257368.007B3CAE-88257368.007C964D@us.ibm.com>
References: <4702B2C0.2070004@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:54734 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010AbXJBWmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 18:42:00 -0400
In-Reply-To: <4702B2C0.2070004@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian,
        I don't think a few instructions is a performance issue in the 
redirect
paths (it'd be pretty broken if you're getting or generating lots of 
them), but I
know there are lots of other checks similar to that that will break with 
new
attributes, so doing that as a general clean-up separately is ok with me, 
too.

With the error message changes, you can add:

Acked-by: David L Stevens <dlstevens@us.ibm.com>

FWIW. :-)

                                                +-DLS


