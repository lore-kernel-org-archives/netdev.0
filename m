From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [Patch net] bridge: fix netconsole setup over bridge
Date: Fri, 07 Feb 2014 09:50:40 +0900
Message-ID: <52F42DE0.1010607@lab.ntt.co.jp>
References: <1391727652-12520-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:41875 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbaBGAuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 19:50:54 -0500
In-Reply-To: <1391727652-12520-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2014/02/07 8:00), Cong Wang wrote:
> From: Cong Wang <cwang@twopensource.com>
> 
> Commit 93d8bf9fb8f3 ("bridge: cleanup netpoll code") introduced
> a check in br_netpoll_enable(), but this check is incorrect for
> br_netpoll_setup(). This patch moves the code after the check
> into __br_netpoll_enable() and calls it in br_netpoll_setup().
> For br_add_if(), the check is still needed.
> 

Acked-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Tested-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Thanks,
Toshiaki Makita
