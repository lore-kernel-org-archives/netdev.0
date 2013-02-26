From: Joe Perches <joe@perches.com>
Subject: Re: [RFC/RFT 00/27] Updates for the rtlwifi family of drivers
Date: Mon, 25 Feb 2013 18:22:37 -0800
Message-ID: <1361845357.2023.7.camel@joe-AO722>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42670 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760056Ab3BZCWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2013 21:22:40 -0500
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-25 at 18:13 -0600, Larry Finger wrote:
> This set of patches upgrades drivers rtlwifi, rtl8192c, rtl8192ce, rtl8192se,
> and rtl8723ae to the state of the vendor driver issued on 2013.02.07. In
> addition, a new driver for the RTL8188EE chip is added to the kernel.
> 
> Note: These patches do not upgrade rtl8192de. Those changes will be sent
> later.

rtl8188e isn't very kernel stylish.
Looking at it briefly, in fact it's kind of ugly.

Could/should it go into staging?
