From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: NULL pointer dereference in net_rx_action
Date: Fri, 13 Jan 2012 17:49:28 +0100
Message-ID: <20120113164928.GA4418@electric-eye.fr.zoreil.com>
References: <CAO+b5-q3DVHQTG1ZKB_tfqjrdokgOdZA4G5QrJ7LFQPhOMHu6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50337 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260Ab2AMQ7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 11:59:12 -0500
Content-Disposition: inline
In-Reply-To: <CAO+b5-q3DVHQTG1ZKB_tfqjrdokgOdZA4G5QrJ7LFQPhOMHu6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bart Van Assche <bvanassche@acm.org> :
[...]
> If I send enough data via netconsole and an Ethernet interface to a
> remote system, sooner or later a NULL pointer dereference is triggered
> in net_rx_action(). I can reproduce this with both 3.1.8 and 3.2.0. Is
> this a known issue ?

I have not seen where netpoll would avoid calling napi methods from bh
disabled context so it is probably "known". You may try to turn the 
bh disabling locks in skge into irq saving ones. Event if (big if) it
works, it will be more a local workaround more than a real solution.

-- 
Ueimor
