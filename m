From: Phil Reid <preid@electromag.com.au>
Subject: stmmac: Reporting ethtool_ts_info
Date: Tue, 27 Oct 2015 14:11:03 +0800
Message-ID: <562F1577.8040803@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchovy2.45ru.net.au ([203.30.46.146]:49668 "EHLO
	anchovy.45ru.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751937AbbJ0GRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 02:17:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

G'day All,

The stmmac driver checks (priv->hwts_tx_en) && (priv->hwts_rx_en) before 
reporting WHTSTAMP capabilities.
No other driver seems to do this. hwts_*_en indicate if timestamping is 
enabled, not if the interface is capable of it.
Instead they check there capabilities. Which would be 
(priv->dma_cap.time_stamp || priv->dma_cap.atime_stamp)

Does this seem reasonable?


-- 
Regards
Phil Reid
