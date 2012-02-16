From: hayeswang <hayeswang@realtek.com>
Subject: RE: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Thu, 16 Feb 2012 14:40:20 +0800
Message-ID: <33249D172FBD4AE09E24D4F24E973BD9@realtek.com.tw>
References: <20120215163748.GA3998@elliptictech.com> <1329333239.2469.3.camel@edumazet-laptop> <20120215232303.GB31463@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Nick Bowler' <nbowler@elliptictech.com>, <netdev@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>,
	'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:38996 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754004Ab2BPGuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 01:50:05 -0500
In-Reply-To: <20120215232303.GB31463@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
> 
> Mac addresses and ip addresses match.
> 
> Hayes, what is the story with ICMP packets and IP flags ?
> 

Please add Cfg9346_Unlock before calling rtl_hw_jumbo_enable or
hw_jumbo_disable.
And, add Cfg9346_lock after calling rlt_hw_jumbo_enable or hw_jumbo_disable. 

Best Regards,
Hayes
