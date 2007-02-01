From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix a race between PCI probe and dev_open
Date: Thu, 1 Feb 2007 09:17:27 +0100
Message-ID: <20070201081727.GA1011@electric-eye.fr.zoreil.com>
References: <20070131213428.GA17534@electric-eye.fr.zoreil.com> <Pine.LNX.4.64.0701311655050.3632@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	jgarzik@pobox.com, Bernhard Walle <bwalle@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58058 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422656AbXBAIXF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 03:23:05 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0701311655050.3632@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> :
[...]
> Doesn't this basically mean that *any* use of "rtl8169_set_speed()" is 
> buggy?

The second use of rtl8169_set_speed is in the change_mtu handler which
performs a complete down/cycle after a release of the timer. It's still
ugly though. If the current buggy behavior can be lived with, I'll
happily postpone the needed deeper changes.

-- 
Ueimor
