From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: build breakage due to br_multicast.c referencing
 ipv6_dev_get_saddr()
Date: Wed, 16 Mar 2011 09:41:56 -0700
Message-ID: <20110316094156.204e4903@nehalam>
References: <4D80BC5B0200007800036D85@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linus.luessing@web.de>, <davem@davemloft.net>,
	<bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>
To: "Jan Beulich" <JBeulich@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40140 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752334Ab1CPQmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 12:42:11 -0400
In-Reply-To: <4D80BC5B0200007800036D85@vpn.id2.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Mar 2011 12:34:19 +0000
"Jan Beulich" <JBeulich@novell.com> wrote:

> With BRIDGE=y and IPV6=m commit
> fe29ec41aaa51902aebd63658dfb04fe6fea8be5 ("bridge: Use IPv6
> link-local address for multicast listener queries") causes the build to
> break.

I have no problem building with 2.6.38 and BRIDGE=y and IPV6=m.
Blacklisting ipv6 module is just self inflicted pain, don't do it.


