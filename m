From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH v2] bonding: send IPv6 neighbor advertisement on failover
Date: Fri, 10 Oct 2008 08:03:09 -0700
Message-ID: <OFB8A232B8.61496942-ON882574DE.0051B425-882574DE.0052AFD3@us.ibm.com>
References: <48EF6812.2090600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>, fubar@linux.vnet.ibm.com,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:35455 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761639AbYJJPDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 11:03:24 -0400
In-Reply-To: <48EF6812.2090600@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote on 10/10/2008 07:34:58 AM:

> I don't really want to since this is bonding-specific behavior, and 
> we're not performing DAD for the address.  This is just another sysfs 
> entry: /sys/class/net/bond*/bonding/num_unsol_na, not a sysctl.

        I think they really are the same case, and doing DAD
would solve the problem just as well. But I can hold my nose a
little bit and live with it. :-) Getting the problem solved is
more important than the details.

                                                        +-DLS

