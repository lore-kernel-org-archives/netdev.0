From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [IPv6] Update setsockopt(IPV6_MULTICAST_IF) to support RFC 3493
Date: Wed, 10 Oct 2007 13:45:38 -0700
Message-ID: <OF75CC6365.1CACD211-ON88257370.0071BBE2-88257370.0071F400@us.ibm.com>
References: <470CEA05.8080809@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:57922 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755514AbXJJUpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 16:45:45 -0400
In-Reply-To: <470CEA05.8080809@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What about just checking for 0 in the later test?

        if (val && __dev_get_by_index(val) == NULL) {
...


                                        +-DLS

