From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6]: Fix crash in ip6_del_rt
Date: Sun, 06 Aug 2006 22:23:41 -0700 (PDT)
Message-ID: <20060806.222341.59467518.davem@davemloft.net>
References: <44D6CD49.4090100@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26838
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751064AbWHGFXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 01:23:43 -0400
To: kaber@trash.net
In-Reply-To: <44D6CD49.4090100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 07 Aug 2006 07:19:05 +0200

> [IPV6]: Fix crash in ip6_del_rt
>
> ip6_null_entry doesn't have rt6i_table set, when trying to delete it the
> kernel crashes dereferencing table->tb6_lock.
>
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
