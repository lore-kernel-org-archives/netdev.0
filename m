From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPv6] rules: Use RT6_LOOKUP_F_HAS_SADDR and fix source based
 selectors
Date: Thu, 12 Oct 2006 18:55:51 +0900 (JST)
Message-ID: <20061012.185551.31808845.yoshfuji@linux-ipv6.org>
References: <20061012094124.GH12964@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	kim.nordlund@nokia.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:26635 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1161546AbWJLJxY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 05:53:24 -0400
To: tgraf@suug.ch, vnuorval@tcs.hut.fi
In-Reply-To: <20061012094124.GH12964@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20061012094124.GH12964@postel.suug.ch> (at Thu, 12 Oct 2006 11:41:24 +0200), Thomas Graf <tgraf@suug.ch> says:

> Fixes rt6_lookup() to provide the source address in the flow
> and sets RT6_LOOKUP_F_HAS_SADDR whenever it is present in
> the flow.
> 
> Avoids unnecessary prefix comparisons by checking for a prefix
> length first.
> 
> Fixes the rule logic to not match packets if a source selector
> has been specified but no source address is available.
> 
> Thanks to Kim Nordlund <kim.nordlund@nokia.com> for working
> on this patch with me.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I tend to agree.  Ville, do you agree?

--yoshfuji
