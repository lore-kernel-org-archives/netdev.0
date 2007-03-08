From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: netlink regression (since 2.6.18)
Date: Thu, 8 Mar 2007 13:28:18 -0800
Message-ID: <20070308132818.4c12830c@freekitty>
References: <20070307142830.307979e6@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:37201 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030480AbXCHVbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 16:31:44 -0500
In-Reply-To: <20070307142830.307979e6@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Mar 2007 14:28:30 -0800
Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> On a Ubuntu x86_64 machine the command: 
>   tc qdisc ls
> gets a RTNETLINK error. It looks like some data structure alignment
> issue got introduced between 2.6.18 and 2.6.19-rc1 and continues on. 
> Since netlink data structure layout is part of the user ABI, we need to go back
> and keep compatibility.
> 
> Still working out the bisect to find where the problem started.

Never mind, it turned out that NET_SCHED wasn't configured on that machine.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
