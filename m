From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net: santize headers for iproute2
Date: Mon, 31 Dec 2007 10:55:29 -0800
Message-ID: <20071231105529.162bf5d8@deepthought>
References: <20071225124323.70e0c772@deepthought>
	<20071225.150238.193724414.davem@davemloft.net>
	<20071225171310.1c43a0e2@deepthought>
	<20071229.192212.149111967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59523 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751091AbXLaS5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 13:57:17 -0500
In-Reply-To: <20071229.192212.149111967.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Glib 2.7 version of netinet/tcp.h works for building iproute2,
but since iproute needs to build on older versions of glibc;
for now, I'll just put a corrected version of netinet/tcp.h in the iproute2
build tree. 
