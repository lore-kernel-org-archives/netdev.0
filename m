From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: Correctly set flow*i_mark and
 flow4i_proto in route lookups
Date: Tue, 05 May 2015 19:38:23 -0400 (EDT)
Message-ID: <20150505.193823.2265457221484975510.davem@davemloft.net>
References: <0a768060aa39d1dfbad87ebc8bcbfd0e4a04c1a7.1430831084.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932745AbbEEXiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:38:25 -0400
In-Reply-To: <0a768060aa39d1dfbad87ebc8bcbfd0e4a04c1a7.1430831084.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue,  5 May 2015 15:09:21 +0200

> VXLAN must provide the skb mark and specifiy IPPROTO_UDP when doing
> the FIB lookup for the remote ip. Otherwise an invalid route might
> be returned.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
