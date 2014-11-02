From: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>
Subject: Arndale ethernet regression
Date: Sun, 2 Nov 2014 16:12:00 +0000
Message-ID: <20141102161200.GM23178@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: m.stam@fugro.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guys,

I have been having an issue with the ethernet on Arndale and it
bisects down to this commit:

commit 3cc81d85ee01e5a0b7ea2f4190e2ed1165f53c31
Author: Michel Stam <m.stam@fugro.nl>
asix: Don't reset PHY on if_up for ASIX 88772

I am afraid I am not overly familiar with the USB or networking
subsystems. But are we sure this patch is good? It seems to set
the reset callback to the link_reset function which feels a
little odd from my layman perspective. It doesn't look like there
could be any config settings or such that I am missing relating
to this patch.

Thanks,
Charles
