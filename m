From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] tg3: Remove unused cfgspc device members
Date: Sun, 21 Dec 2008 20:22:27 -0800 (PST)
Message-ID: <20081221.202227.64072877.davem@davemloft.net>
References: <1229717360.5502@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41165
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752971AbYLVEWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 23:22:25 -0500
In-Reply-To: <1229717360.5502@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 17 Dec 2008 18:23:13 -0800

> This patch removes the pci_bist and pci_hdr_type members from the
> device structure and removes the code that references them.  They are
> not really used.
> 
> The patch rounds out the changes by moving the pci_cmd member to plug
> a structure hole that would have been created.  On 32-bit systems, this
> movement removes a subsequent structure hole later in the structure. On
> 64-bit systems though, the movement merely consolidates two holes into
> one larger hole.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
