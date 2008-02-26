From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC/PATCH] ipg: add jumbo frame support kconfig option
Date: Tue, 26 Feb 2008 12:32:47 -0800
Message-ID: <20080226123247.2b63bbf0@extreme>
References: <Pine.LNX.4.64.0802262148270.12999@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35107 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765028AbYBZUcy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 15:32:54 -0500
In-Reply-To: <Pine.LNX.4.64.0802262148270.12999@sbz-30.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Pekka Enberg <penberg@cs.helsinki.fi>
> 
> Convert the internal JUMBO_FRAME #ifdef to CONFIG_IP1000_JUMBO_FRAME proper and
> fix compilation errors.
> 
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Sorbica Shieh <sorbica@icplus.com.tw>
> Cc: Jesse Huang <jesse@icplus.com.tw>
> Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>

Please don't do this as a config option. Config options seem like a good idea
to developers but are difficult for distributions.  Either support jumbo
frames by default or not at all.
