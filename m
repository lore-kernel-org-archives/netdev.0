From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND 1/2] [NETLINK]: Improve string attribute validation
Date: Sat, 26 Aug 2006 20:11:57 -0700 (PDT)
Message-ID: <20060826.201157.106264876.davem@davemloft.net>
References: <20060822125354.196502354@postel.suug.ch>
	<20060822125840.307365394@postel.suug.ch>
	<20060822134049.GF3470@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:34470
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751144AbWH0DMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 23:12:06 -0400
To: tgraf@suug.ch
In-Reply-To: <20060822134049.GF3470@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 22 Aug 2006 15:40:49 +0200

> Searching for '\0' with strnchr() doesn't really work :-)
> 
> Introduces a new attribute type NLA_NUL_STRING to support NUL
> terminated strings. Attributes of this kind require to carry
> a terminating NUL within the maximum specified in the policy.
> 
> The `old' NLA_STRING which is not required to be NUL terminated
> is extended to provide means to specify a maximum length of the
> string.
> 
> Aims at easing the pain with using nla_strlcpy() on temporary
> buffers.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
