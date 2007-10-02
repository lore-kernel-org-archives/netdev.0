From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [IPv6] Fix ICMPv6 redirect handling with target multicast address
Date: Tue, 2 Oct 2007 13:39:23 -0700
Message-ID: <OF939F3A2D.96830882-ON88257368.007068EA-88257368.007161DC@us.ibm.com>
References: <4702997D.6020208@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:52839 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbXJBUj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 16:39:28 -0400
In-Reply-To: <4702997D.6020208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian,
        ipv6_addr_type() returns a mask, so checking for equality will 
fail to
match if  any other (irrelevant) attributes are set. How about using 
bitwise
operators for that? Also, the error message is no longer descriptive of 
the
failure if it's a link-local multicast, but you could make it "target 
address is not
link-local unicast.\n" (in both places).

                                                +-DLS

