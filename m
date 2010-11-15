From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] network: return errors if we know tcp_connect
 failed
Date: Mon, 15 Nov 2010 08:46:09 -0800 (PST)
Message-ID: <20101115.084609.71124618.davem@davemloft.net>
References: <1289836066.14282.7.camel@localhost.localdomain>
	<4CE15885.90003@trash.net>
	<4CE16198.7000709@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, hzhong@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4CE16198.7000709@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 15 Nov 2010 17:36:40 +0100

> Patch for demonstration purposes attached. I've modified the
> MARK target so it returns NF_DROP with an errno code of
> -ECONNREFUSED:

I'm fine with the tcp_output.c changes.
