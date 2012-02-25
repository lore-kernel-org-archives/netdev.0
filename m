From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: Re: [PATCH 12/12] rose: check given MAC address, if invalid return -EADDRNOTAVAIL
Date: Sat, 25 Feb 2012 19:25:28 +0100
Message-ID: <201202251925.30283.danny.kukawka@bisect.de>
References: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de> <20120224161358.17df7421@pyramind.ukuu.org.uk> <20120224.154335.577711354132386075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, ralf@linux-mips.org,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20120224.154335.577711354132386075.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Freitag, 24. Februar 2012, David Miller wrote:
> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Date: Fri, 24 Feb 2012 16:13:58 +0000
>
> > On Fri, 24 Feb 2012 17:01:22 +0100
> >
> > Danny Kukawka <danny.kukawka@bisect.de> wrote:
> >> Check if given address is valid in .ndo_set_mac_address/
> >> rose_set_mac_address(), if invalid return -EADDRNOTAVAIL as
> >> eth_mac_addr() already does if is_valid_ether_addr() fails.
> >
> > This patch series looks wrong - you cannot go blindly applying ethernet
> > mac address tests to device drivers without checking if they are using
> > 802.11 type addressing at the physical level.

Overseen this aspect ... Sorry. I'll check the patches and send an updated 
version.

Do you mean 802.3 ? 

Danny
