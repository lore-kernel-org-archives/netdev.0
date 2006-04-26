From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] bridge: partial rtnetlink hooks
Date: Wed, 26 Apr 2006 15:43:51 -0700 (PDT)
Message-ID: <20060426.154351.14477425.davem@davemloft.net>
References: <20060426104521.44682924@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11203
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932422AbWDZWnz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 18:43:55 -0400
To: shemminger@osdl.org
In-Reply-To: <20060426104521.44682924@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 26 Apr 2006 10:45:21 -0700

> +struct brifinfo {
> +	__u8	state;
> +	__u32	cost;
> +};
> +

Maybe put the __u32 first and explicitly pad out the 3
bytes after the __u8?  Just to be safe.

I know you use an assignment initializer, so your current
code won't leak kernel data into userspace, but a safer
layout might help provide even more protection for future
code using this data structure.
