From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] eth: reset addr_assign_type if eth_mac_addr()
 called
Date: Mon, 13 Feb 2012 00:50:03 -0500 (EST)
Message-ID: <20120213.005003.188848469193975189.davem@davemloft.net>
References: <1328816934-11508-1-git-send-email-danny.kukawka@bisect.de>
	<1328816934-11508-2-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dkukawka@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nhorman@tuxdriver.com,
	eric.dumazet@gmail.com, rdunlap@xenotime.net
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328816934-11508-2-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Thu,  9 Feb 2012 20:48:53 +0100

> If eth_mac_addr() get called, usually if SIOCSIFHWADDR was
> used to change the MAC of a ethernet device, reset the
> addr_assign_type to NET_ADDR_PERM if the state was
> NET_ADDR_RANDOM before. Reset the state since the MAC is
> no longer random at least not from the kernel side.
> 
> v2: changed to bitops, removed if()
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Applied.
