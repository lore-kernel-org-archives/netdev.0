From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] When timestamping is enabled, stmmac_tx_clean will call stmmac_get_tx_hwtstamp to get tx TS. It's possible that skb is NULL because there are other network frames that use several descriptors. So we must return immediately in stmmac_get_tx_hwtstamp if skb is NULL to avoid system crash.
Date: Sun, 12 Jan 2014 08:20:35 +0100
Message-ID: <20140112072035.GD6586@order.stressinduktion.org>
References: <1389492095-6589-1-git-send-email-damuzi000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: damuzi000 <damuzi000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57684 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbaALHUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 02:20:37 -0500
Content-Disposition: inline
In-Reply-To: <1389492095-6589-1-git-send-email-damuzi000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 12, 2014 at 10:01:35AM +0800, damuzi000 wrote:
> 
> Signed-off-by: damuzi000 <damuzi000@gmail.com>

Please use real names in submissions.

Thanks,

  Hannes
