From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH 1/3] [IPV6] Remove unused macro (MLDV2_QQIC) from mcast.c.
Date: Wed, 23 Apr 2008 07:47:52 -0700
Message-ID: <OF78FBCDB5.F62220EB-ON88257434.00508BE6-88257434.005148DA@us.ibm.com>
References: <eb3ff54b0804230434m5a844cf9w4b2ee074bce832c0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: "Rami Rosen" <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:58245 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459AbYDWOsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 10:48:03 -0400
In-Reply-To: <eb3ff54b0804230434m5a844cf9w4b2ee074bce832c0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The QQIC field is only used by multicast routers.

I don't object strongly to removing it, but it doesn't really save much
and it's potentially useful for debug printing or simply documenting how
to decode the field. So, I would leave it, but I agree it isn't a 
requirement
if Yoshifuji or Dave thinks it's better to remove it.

                                                +-DLS

