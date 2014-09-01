From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v3] lib/rhashtable: allow user to set the
 minimum shifts of shrinking
Date: Mon, 1 Sep 2014 10:41:26 +0100
Message-ID: <20140901094126.GD27933@casper.infradead.org>
References: <1409381306-7036-1-git-send-email-ying.xue@windriver.com>
 <20140901090302.GB27933@casper.infradead.org>
 <54043C45.7090005@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56082 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629AbaIAJl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 05:41:28 -0400
Content-Disposition: inline
In-Reply-To: <54043C45.7090005@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/14 at 05:28pm, Ying Xue wrote:
> Do you think it's worth replacing max() macro with max_t() regarding
> above suggestion?

Yes. max_t() is what should be used in this case.

> By the way, if the replacement should do, all max() macro in the
> lib/rhashtable.c should be replaced as well.

I think the other max() usage is fine as both arguments have a type (size_t).
