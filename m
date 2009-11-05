From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH testing] Do not call IPv4 specific func in tcp_check_req
Date: Wed, 04 Nov 2009 23:22:14 -0800 (PST)
Message-ID: <20091104.232214.23355826.davem@davemloft.net>
References: <7916.1257300093@turing-police.cc.vt.edu>
	<1257352854-19490-1-git-send-email-gilad@codefidence.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, netdev@vger.kernel.org, ori@comsleep.com,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: gilad@codefidence.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48181
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750825AbZKEHVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 02:21:49 -0500
In-Reply-To: <1257352854-19490-1-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gilad Ben-Yossef <gilad@codefidence.com>
Date: Wed,  4 Nov 2009 18:40:54 +0200

> Calling IPv4 specific inet_csk_route_req in tcp_check_req
> is a bad idea and crashes machine on IPv6 connections, as reported
> by Valdis Kletnieks
> 
> Also, all we are really interested in is the timestamp
> option in the header, so calling tcp_parse_options()
> with the "estab" set to false flag is an overkill as
> it tries to parse half a dozen other TCP options.
> 
> We know whether timestamp should be enabled or not
> using data from request_sock.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>

Applied, thanks.

I assume that your other patch which attempted to fix this isn't
necessary.
