From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [2.6.25 patch] fix broken error handling in
	ieee80211_sta_process_addba_request()
Date: Wed, 20 Feb 2008 06:46:13 +0000
Message-ID: <20080220064613.GA3885@ff.dom.local>
References: <20080219225852.GQ31955@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ron Rindjunsky <ron.rindjunsky@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:18090 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbYBTGpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 01:45:21 -0500
Received: by an-out-0708.google.com with SMTP id d31so591345and.103
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 22:45:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080219225852.GQ31955@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19-02-2008 23:58, Adrian Bunk wrote:
...
> --- a/net/mac80211/ieee80211_sta.c
> +++ b/net/mac80211/ieee80211_sta.c
> @@ -1116,9 +1116,10 @@ static void ieee80211_sta_process_addba_request(struct net_device *dev,
...
> +			printk(KERN_ERR "can not allocate reordering buffer "

  +			printk(KERN_ERR "cannot allocate reordering buffer "

Probably this can be fixed during the commit.

Jarek P.
