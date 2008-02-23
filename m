From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: Re: [PATCH] [PS3] gelic wireless driver needs MAC80211 support
Date: Sat, 23 Feb 2008 21:15:35 +0100
Message-ID: <20080223201535.GC7135@Chamillionaire.breakpoint.cc>
References: <20080223193517.GA6704@Chamillionaire.breakpoint.cc> <200802232044.59887.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Masakazu Mokuno <mokuno@sm.sony.co.jp>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:46899 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754672AbYBWUPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 15:15:46 -0500
Content-Disposition: inline
In-Reply-To: <200802232044.59887.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ivo van Doorn | 2008-02-23 20:44:59 [+0100]:

>Is there any particular reason why this driver is in drivers/net instead
>of drivers/net/wireless (along with all other wireless drivers?

My understanding is/was that the wireless device and the eth device are
exposed by the hypervisor to the system and they share ressources.

Sebastian
