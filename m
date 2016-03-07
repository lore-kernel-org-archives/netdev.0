From: Holger Schurig <holgerschurig@gmail.com>
Subject: Re: 4.4.3: OOPS when running "stress-ng --sock 5"
Date: Mon, 07 Mar 2016 10:12:55 +0100
Message-ID: <87fuw2d52g.fsf@gmail.com>
References: <87twkmd6or.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org, kernel-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37034 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407AbcCGJNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 04:13:00 -0500
In-Reply-To: <87twkmd6or.fsf@gmail.com> (Holger Schurig's message of "Fri, 04
	Mar 2016 08:48:52 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I compared my config with imx_v6_v7_defconfig which didn't segfault.

After I turned on CONFIG_SWAP, my segfault vanished.

I did turn off CONFIG_SWAP because my device only has SD-Card and eMMC.
So I never intended to create a swap partition. And thought "why compile
it in the kernel when I never use it?".

But it seems the kernel is instable with this setting.

So we have a potential denial-of-service in kernels compiled without
CONFIG_SWAP, don't we? At least when it comes to skb handling.

Other memory tests never showed anything weird, and my system is running
X11 with some Qt applications as well as Java applications since about a
year without trouble. During all this time without CONFIG_SWAP.
