From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] r8169: Don't claim WoL works if LanWake flag is not
 set
Date: Fri, 11 Dec 2015 01:06:27 +0100
Message-ID: <20151211000627.GA3705@electric-eye.fr.zoreil.com>
References: <1449655730-3328-1-git-send-email-vinschen@redhat.com>
 <1449657826-4461-1-git-send-email-vinschen@redhat.com>
 <20151209224306.GA5082@electric-eye.fr.zoreil.com>
 <20151210095135.GA21583@calimero.vinschen.de>
 <20151210204054.GA30391@electric-eye.fr.zoreil.com>
 <20151210220255.GB3507@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Chun-Hao Lin <hau@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59187 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbLKAGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 19:06:39 -0500
Content-Disposition: inline
In-Reply-To: <20151210220255.GB3507@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
[...]
> It's still a bit weird.  On the machines I tested this on, if I disable
> LanWake and shutdown the machine, I can send, e.g., MagicPackets as much
> as I like, the machined don't come up.  Isn't it a bit misleading then
> if ethtool reports that some WoL method is enabled but it doesn't work?

Of course it is. :o(

I'm fine with Config5.LanWake changes if you have empirical evidences that
it helps.

We have terse - outdated ? - documentation and some hint from
http://marc.info/?l=linux-netdev&m=137654699802446. I'm unable to figure
what an/the adequate change could be, especially a low level chance of
regression one.

-- 
Ueimor
