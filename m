From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.15-rc6: known regressions in the kernel Bugzilla
Date: Thu, 22 Dec 2005 07:16:51 -0800 (PST)
Message-ID: <20051222.071651.43525556.davem@davemloft.net>
References: <Pine.LNX.4.64.0512181641580.4827@g5.osdl.org>
	<20051222011320.GL3917@stusta.de>
	<20051222005209.0b1b25ca.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, torvalds@osdl.org, linux-kernel@vger.kernel.org,
	aabdulla@nvidia.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	ak@suse.de, discuss@x86-64.org, perex@suse.cz,
	alsa-devel@alsa-project.org, gregkh@suse.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030196AbVLVPRP@vger.kernel.org>
To: akpm@osdl.org
In-Reply-To: <20051222005209.0b1b25ca.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Thu, 22 Dec 2005 00:52:09 -0800

> From: Charles-Edouard Ruault <ce@ruault.com>
> Subject: [BUG] kernel 2.6.14.2 breaks IPSEC

Herbert's reply at the end of the thread explains that what the user
is doing, applying SNAT to IPSEC, has undefined results currently.

Using netfilter with IPSEC is known to be broken since the beginning
of our IPSEC implementation, and we plan to cure it in 2.6.16 with
some excellent work done by Patrick McHardy and Herbert Xu.

So just remove that from your list please, thanks.
