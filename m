From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.2)
Date: Wed, 5 Jan 2011 22:53:08 -0800
Message-ID: <20110105225308.70d5888f@nehalam>
References: <20110104162930.6fa672e3@nehalam>
	<1294208375.3420.46.camel@edumazet-laptop>
	<20110105091718.02f8a00f@nehalam>
	<1294248332.10633.25.camel@edumazet-laptop>
	<20110105112104.64ad3c86@nehalam>
	<1294286850.2723.65.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48262 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753940Ab1AFGxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 01:53:12 -0500
In-Reply-To: <1294286850.2723.65.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 Jan 2011 05:07:30 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> - CHOKe should be able to use an external flow classifier (like say...
> SFQ) to compute a token and compare two skbs by this token instead of
> custom rxhash or whatever.

I don't think you can apply a filter to a non-classful qdisc?


