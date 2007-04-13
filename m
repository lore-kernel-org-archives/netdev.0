From: David Howells <dhowells@redhat.com>
Subject: Re: Getting a network interface list from within the kernel
Date: Fri, 13 Apr 2007 12:37:18 +0100
Message-ID: <25286.1176464238@redhat.com>
References: <20070412.135951.38690236.davem@davemloft.net>  <2970.1176411110@redhat.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59092 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833AbXDMLhc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Apr 2007 07:37:32 -0400
In-Reply-To: <20070412.135951.38690236.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> Issue a RTM_GETLINK rtnetlink request, and parse the response.

Okay, I've managed to find code that does this.  However, RTM_GETLINK does not
appear to return any IPv4 addressing information.  It does, however, contain
the MTU details which is one of the three things I wanted.

I found that RTM_GETADDR will give me the IPv4 address and something from
which I can calculate the netmask.

I don't suppose there's a single op that will allow me to get all three in one
go?

Oh, and can I assume that the interface index numbers returned by RTM_GETLINK
match those returned by RTM_GETADDR?  Even if an interface is removed between
issuing the two calls?  Alternatively, do I need to compare interface names as
those are available between both?

David
