From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH v3 net-next] sockopt: Change getsockopt() of SO_BINDTODEVICE
 to return an interface name
Date: Wed, 28 Nov 2012 00:36:01 +0400
Message-ID: <50B52431.5090800@parallels.com>
References: <50B388E4.7030600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:48941 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755832Ab2K0UgS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 15:36:18 -0500
In-Reply-To: <50B388E4.7030600@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2012 07:21 PM, Brian Haley wrote:
> Instead of having the getsockopt() of SO_BINDTODEVICE return an index, which
> will then require another call like if_indextoname() to get the actual interface
> name, have it return the name directly.
> 
> This also matches the existing man page description on socket(7) which mentions
> the argument being an interface name.
> 
> If the value has not been set, zero is returned and optlen will be set to zero
> to indicate there is no interface name present.
> 
> Added a seqlock to protect this code path, and dev_ifname(), from someone
> changing the device name via dev_change_name().
> 
> v2: Added seqlock protection while copying device name.
> 
> v3: Fixed word wrap in patch.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Acked-by: Pavel Emelyanov <xemul@parallels.com>
