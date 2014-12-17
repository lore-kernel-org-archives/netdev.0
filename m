From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 1/2] geneve: Remove socket and offload handlers at
 destruction.
Date: Wed, 17 Dec 2014 16:41:15 +0000
Message-ID: <20141217164115.GD28766@casper.infradead.org>
References: <1418783132-99230-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andy Zhou <azhou@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56091 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbaLQQlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 11:41:16 -0500
Content-Disposition: inline
In-Reply-To: <1418783132-99230-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/14 at 06:25pm, Jesse Gross wrote:
> Sockets aren't currently removed from the the global list when
> they are destroyed. In addition, offload handlers need to be cleaned
> up as well.
> 
> Fixes: 0b5e8b8e ("net: Add Geneve tunneling protocol driver")
> CC: Andy Zhou <azhou@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
