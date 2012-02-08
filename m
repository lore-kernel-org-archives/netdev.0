From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 01/50] eth: reset addr_assign_type if eth_mac_addr()
 called
Date: Wed, 8 Feb 2012 14:50:04 -0800
Message-ID: <20120208145004.171e4d54@nehalam.linuxnetplumber.net>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
	<1328735457-29986-2-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-2-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  8 Feb 2012 22:10:08 +0100
Danny Kukawka <danny.kukawka@bisect.de> wrote:

> +	if (dev->addr_assign_type & NET_ADDR_RANDOM)
> +		dev->addr_assign_type ^= NET_ADDR_RANDOM;

Why not just avoid the conditional, or better yet use bitops?

	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
