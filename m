From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] geneve: use network byte order for destination port
 config parameter
Date: Wed, 23 Sep 2015 15:41:36 -0700 (PDT)
Message-ID: <20150923.154136.1784019012935564685.davem@davemloft.net>
References: <20150922152504.GA18514@tuxdriver.com>
	<1442941772-11148-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, jesse@nicira.com,
	eric.dumazet@gmail.com, stephen@networkplumber.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755137AbbIWWlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 18:41:37 -0400
In-Reply-To: <1442941772-11148-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 22 Sep 2015 13:09:32 -0400

> This is primarily for consistancy with vxlan and other tunnels which
> use network byte order for similar parameters.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> It is OK to change this, since this parameter was introduced to
> net-next in the pre-4.3 cycle.  Using network byte order for this
> parameter is consistent with what the other tunnels are doing.
> 
> v2 -- rebase on current net tree...

Applied, thanks John.
