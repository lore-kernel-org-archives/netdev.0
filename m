From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] make ipv4 multicast packets only get delivered to sockets	that
 are joined to group
Date: Wed, 13 Sep 2006 13:42:02 -0700
Message-ID: <OFD3BF4B0D.1F917BE2-ON882571E8.00716451-882571E8.0071B6B7@us.ibm.com>
References: <20060913202029.GA4666@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Jeff Layton <jlayton@poochiereds.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:6831 "EHLO e34.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751180AbWIMUmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 16:42:06 -0400
In-Reply-To: <20060913202029.GA4666@ms2.inr.ac.ru>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote on 09/13/2006 01:20:29 PM:

> Hello!
> 
> > IPv6 behaves the same way.
> 
> Actually, Linux IPv6 filters received multicasts, inet6_mc_check() does
> this.

        No, it returns 1 (allow) if there are no filters to explicitly
filter it. I wrote that code. :-)
                                                        +-DLS

