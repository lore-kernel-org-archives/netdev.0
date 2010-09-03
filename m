From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv6: add special mode forwarding=2 to send RS while
 configured as router
Date: Fri, 3 Sep 2010 08:00:19 -0700
Message-ID: <20100903080019.65ee4905@nehalam>
References: <20100903130420.GB28460@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60779 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754921Ab0ICPAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 11:00:21 -0400
In-Reply-To: <20100903130420.GB28460@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 3 Sep 2010 09:04:20 -0400
Thomas Graf <tgraf@infradead.org> wrote:

> Similar to accepting router advertisement, the IPv6 stack does not send router
> solicitations if forwarding is enabled.
> 
> This patch enables this behavior to be overruled by setting forwarding to the
> special value 2.
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>
> 

Please add description to Documentation/networking/ip-sysctl.txt
