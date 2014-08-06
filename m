From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH v2] net: reallocate new socket option number for
 IPV6_AUTOFLOWLABEL
Date: Wed, 6 Aug 2014 19:00:22 -0400
Message-ID: <20140806230022.GA23144@redhat.com>
References: <1407363429-3870-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: therbert@google.com, netfilter-devel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753243AbaHFXAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2014 19:00:34 -0400
Content-Disposition: inline
In-Reply-To: <1407363429-3870-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 07, 2014 at 12:17:09AM +0200, Pablo Neira Ayuso wrote:
 > cb1ce2e ("ipv6: Implement automatic flow label generation on transmit")
 > accidentally uses socket option 64, which is already used by ip6tables:
 > 
 >  IP6T_SO_SET_REPLACE / IP6T_SO_GET_INFO               64
 >  IP6T_SO_SET_ADD_COUNTERS / IP6T_SO_GET_ENTRIES       65
 > 
 > There is comment include/uapi/linux/in6.h warning about that.
 > 
 > Allocate 70 for this, which seems to be unused instead.
 > 
 > Cc: Tom Herbert <therbert@google.com>
 > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Just tested this, ip6tables works fine now.

thanks Pablo.

	Dave
