From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] hso: fix problem with wrong status code sent by
 OPTION GTM601 during RING indication
Date: Thu, 03 Oct 2013 15:29:07 -0400 (EDT)
Message-ID: <20131003.152907.2144013596237714581.davem@davemloft.net>
References: <B1808224-5850-41E3-9A8F-0F350F84FF89@goldelico.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.dumon@option.com, marek.belisko@gmail.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hns@goldelico.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <B1808224-5850-41E3-9A8F-0F350F84FF89@goldelico.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dr. H. Nikolaus Schaller" <hns@goldelico.com>
Date: Wed, 2 Oct 2013 09:00:18 +0200

> From f5c7e15b61f2ce4fe3105ff914f6bfaf5d74af0d Mon Sep 17 00:00:00 2001
> From: "H. Nikolaus Schaller" <hns@goldelico.com>
> Date: Thu, 15 Nov 2012 14:40:57 +0100
> Subject: [PATCH 1/1] hso: fix problem with wrong status code sent by OPTION
>  GTM601 during RING indication
> 
>  It has been observed that the GTM601 with 1.7 firmware sometimes sends a value
>  wIndex that has bit 0x04 set instead of being reset as the code expects. So we
>  mask it for the error check.
>  
>  See http://lists.goldelico.com/pipermail/gta04-owner/2012-February/001643.html
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> Signed-off-by: H. Nikolaus Schaller <hns@goldelico.de>

I think we should look more deeply into what this bit might mean
and why the firmware might be setting it before we even consider
applying a patch like this one.
