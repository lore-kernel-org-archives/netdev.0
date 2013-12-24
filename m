From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCHv2 iptables] iptables: Add IPv4/6 IPcomp match support
Date: Tue, 24 Dec 2013 19:30:40 +0100
Message-ID: <20131224183040.GA27493@localhost>
References: <1387337242-28865-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55751 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752312Ab3LXSao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Dec 2013 13:30:44 -0500
Content-Disposition: inline
In-Reply-To: <1387337242-28865-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 11:27:22AM +0800, Fan Du wrote:
> This patch enables user to set iptables ACTIONs for IPcomp
> flow specified by its SPI value.
> 
> For example:
> iptables  -A OUTPUT -p 108 -m ipcomp --ipcompspi 0x12 -j DROP
> ip6tables -A OUTPUT -p 108 -m ipcomp --ipcompspi 0x12 -j DROP
> 
> IPcomp packet with spi as 0x12 will be dropped.

Applied with minor glitches, thanks.
