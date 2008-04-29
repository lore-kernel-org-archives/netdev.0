From: Jeff Garzik <jeff@garzik.org>
Subject: Re: odd RTL8139 quirk.
Date: Tue, 29 Apr 2008 15:37:41 -0400
Message-ID: <48177905.4000409@garzik.org>
References: <20080429171403.GA21035@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40053 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983AbYD2Tho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 15:37:44 -0400
In-Reply-To: <20080429171403.GA21035@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones wrote:
> I've just been playing with a model 2 OQO, which has an RTL8139.
> It gets detected just fine, though it doesn't actually work..
> 
> eth0: RealTek RTL8139 at 0xf8830000, 00:00:00:00:00:00, IRQ 18
> eth0:  Identified 8139 chip type 'RTL-8139'
> 
> The null MAC address being one clue.  Another oddity is that
> ethtool reports that there's no link detected, even though there is.
> (Enough for it to PXE boot a kernel from at least :)
> 
> Futzing with the debug= modparam didn't yield anything extra at all.
> 
> Any clues?

Sounds like a broken EEPROM.  Does supplying a MAC via ifconfig prior to 
'ifconfig ... up' help?

	Jeff



