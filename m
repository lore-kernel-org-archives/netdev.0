From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] seastar - SeaStar Ethernet driver (review comments
 addressed)
Date: Tue, 2 Feb 2010 18:07:57 -0800
Message-ID: <20100202180757.51078dad@nehalam>
References: <20100202205845.GE5246@hawkeye.sandia.gov>
	<1265159307.15726.4.camel@hawkeye.sandia.gov>
	<1265162522.1945.148.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kevin Pedretti <ktpedre@sandia.gov>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57314 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932185Ab0BCCIS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2010 21:08:18 -0500
In-Reply-To: <1265162522.1945.148.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 Feb 2010 18:02:01 -0800
Joe Perches <joe@perches.com> wrote:

> Presumably SeaStar doesn't support multicast either, so maybe:
> 	if (dest_low_mac & 0x01)

Why not:
        if (is_multicast_ether_addr(ethdr->h_dest))
...
