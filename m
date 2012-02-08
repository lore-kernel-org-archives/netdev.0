From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: Re: [PATCH 01/50] eth: reset addr_assign_type if eth_mac_addr() called
Date: Wed, 8 Feb 2012 23:57:28 +0100
Message-ID: <201202082357.28972.danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de> <1328735457-29986-2-git-send-email-danny.kukawka@bisect.de> <20120208145004.171e4d54@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120208145004.171e4d54@nehalam.linuxnetplumber.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mittwoch, 8. Februar 2012, Stephen Hemminger wrote:
> On Wed,  8 Feb 2012 22:10:08 +0100
>
> Danny Kukawka <danny.kukawka@bisect.de> wrote:
> > +	if (dev->addr_assign_type & NET_ADDR_RANDOM)
> > +		dev->addr_assign_type ^= NET_ADDR_RANDOM;
>
> Why not just avoid the conditional, or better yet use bitops?
>
> 	dev->addr_assign_type &= ~NET_ADDR_RANDOM;

Okay, If I have comments on the other patches back, I will send new versions 
which avoid the if. Thanks for the hint.

Danny
