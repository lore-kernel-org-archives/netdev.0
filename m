From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next] r8169: use unlimited DMA burst for TX
Date: Tue, 11 Sep 2012 16:09:52 +0800
Message-ID: <CAF7E57619E34A17A56F6D13097342EA@realtek.com.tw>
References: <1347234926-5263-1-git-send-email-mschmidt@redhat.com> <20120910.155046.568702072740433838.davem@davemloft.net> <20120910215521.GA930@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <mschmidt@redhat.com>, <netdev@vger.kernel.org>,
	<ivecera@redhat.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>,
	'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:41781 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819Ab2IKIKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 04:10:13 -0400
In-Reply-To: <20120910215521.GA930@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Tuesday, September 11, 2012 5:55 AM
> To: David Miller
> Cc: mschmidt@redhat.com; netdev@vger.kernel.org; Hayeswang; 
> nic_swsd; ivecera@redhat.com
> Subject: Re: [PATCH net-next] r8169: use unlimited DMA burst for TX
> 
> Hayes, should we:
> - mimic Realtek's 8168, 8169 and 810x drivers ?
> - always set TX_DMA_BURST at the max value ?
> - do something different (per chipset) ?

Our hw engineer suggets to set unlimited for both TX_DMA_BURST and RX_DMA_BURST
for all chipsets.
 
Best Regards,
Hayes
