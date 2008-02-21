From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] macb: Fix speed setting
Date: Fri, 22 Feb 2008 00:04:17 +0900 (JST)
Message-ID: <20080222.000417.126763769.anemo@mba.ocn.ne.jp>
References: <20080221.225054.61509660.anemo@mba.ocn.ne.jp>
	<20080221151246.6f2044b9@dhcp-252-066.norway.atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: hskinnemoen@atmel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761473AbYBUPEV@vger.kernel.org>
In-Reply-To: <20080221151246.6f2044b9@dhcp-252-066.norway.atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Feb 2008 15:12:46 +0100, Haavard Skinnemoen <hskinnemoen@atmel.com> wrote:
> I have to admit that even after looking through include/linux/phy.h and
> include/linux/mii.h, I don't have the faintest idea what values we can
> expect to find in the "speed" field of phydev. The comment above struct
> phy_device says that it is used "like in mii_if_info", but struct
> mii_if_info doesn't have a "speed" field...
> 
> I'm willing to take your word for it, but some documentation would be
> really nice...

Well, simple grepping drivers/net/phy
