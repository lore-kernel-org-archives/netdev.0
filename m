From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless 2012-07-06
Date: Mon, 9 Jul 2012 14:43:51 -0400
Message-ID: <20120709184351.GB1348@tuxdriver.com>
References: <20120706192034.GA1879@tuxdriver.com>
 <20120709.003155.284089706826738623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Thomas Huehn <thomas@net.t-labs.tu-berlin.de>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120709.003155.284089706826738623.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 09, 2012 at 12:31:55AM -0700, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Fri, 6 Jul 2012 15:20:35 -0400
> 
> > Please let me know if there are problems!
> 
> This indentation is not correct:
> 
> commit 01f9cb073c827c60c43f769763b49a2026f1a897
> Author: Thomas Huehn <thomas@net.t-labs.tu-berlin.de>
> Date:   Thu Jun 28 14:39:51 2012 -0700
> 
>     mwl8k: fix possible race condition in info->control.sta use
>  ...
> +			sta = ieee80211_find_sta_by_ifaddr(hw, wh->addr1,
> +								wh->addr2);

OK, I'll drop this patch and send a new pull request with a couple more fixes as well.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
