From: Patrick McHardy <kaber@trash.net>
Subject: Re: Broken commit: [NETFILTER]: ipt_REJECT: remove largely duplicate
 route_reverse function
Date: Tue, 28 Nov 2006 20:58:10 +0100
Message-ID: <456C94D2.9000602@trash.net>
References: <m3fyc3e84s.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:14501 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S936077AbWK1T6R
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 14:58:17 -0500
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m3fyc3e84s.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> Hi,
> 
> The following commit breaks ipt_REJECT on my machine. Tested with latest
> 2.6.19rc*, found with git-bisect. i386, gcc-4.1.1, the usual stuff.
> All details available on request, of course.
> 
> commit 9d02002d2dc2c7423e5891b97727fde4d667adf1

How sure are you about this? I can see nothing wrong with that
commit and can't reproduce the slab corruption. Please post
the rule that triggers this.



