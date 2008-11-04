From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: ipv6_addr_type() and mapped IPv4 loopback
Date: Tue, 4 Nov 2008 12:19:15 -0800
Message-ID: <OFAE7E2AD1.D61365A4-ON882574F7.006F25B5-882574F7.006F9FD0@us.ibm.com>
References: <443B1A57-9994-4555-BCE6-B66B8F406DA2@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:54918 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752765AbYKDUTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 15:19:37 -0500
In-Reply-To: <443B1A57-9994-4555-BCE6-B66B8F406DA2@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is actually a difference.

The mapped-v4 loopback address uses IPv4 for packet
delivery while the IPv6 loopback uses IPv6. So, theoretically,
an application using a protocol-specific feature would need
to distinguish between the two.

I don't think it's a good idea to remap those to ::1.

                                        +-DLS

