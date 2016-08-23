From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: strparser: fix strparser sk_user_data
 check
Date: Mon, 22 Aug 2016 22:43:38 -0700 (PDT)
Message-ID: <20160822.224338.167749143257258633.davem@davemloft.net>
References: <20160822192704.GA34359@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: davejwatson@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48428 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752572AbcHWFnj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 01:43:39 -0400
In-Reply-To: <20160822192704.GA34359@davejwatson-mba.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Watson <davejwatson@fb.com>
Date: Mon, 22 Aug 2016 12:27:04 -0700

> sk_user_data mismatch between what kcm expects (psock) and what strparser expects (strparser).
> 
> Queued rx_work, for example calling strp_check_rcv after socket buffer changes, will never complete.
> 
> sk_user_data is unused in strparser, so just remove the check.
> 
> Signed-off-by: Dave Watson <davejwatson@fb.com>

Applied, thanks.
