From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Drop tp arg from rtl8169_tx_vlan_tag()
Date: Sun, 11 Nov 2012 23:18:19 +0100
Message-ID: <20121111221819.GB873@electric-eye.fr.zoreil.com>
References: <1352567462-23174-1-git-send-email-kirr@mns.spb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Kirill Smelkov <kirr@mns.spb.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39883 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab2KKWlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 17:41:15 -0500
Content-Disposition: inline
In-Reply-To: <1352567462-23174-1-git-send-email-kirr@mns.spb.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kirill Smelkov <kirr@mns.spb.ru> :
> Since eab6d18d (vlan: Don't check for vlan group before
> vlan_tx_tag_present.) we don't check tp->vlgrp and thus tp is not needed
> in this function.

Pushed to branch git://violet.fr.zoreil.com/romieu/linux davem-next.r8169

Thanks.

-- 
Ueimor
