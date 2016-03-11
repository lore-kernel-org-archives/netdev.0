From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/6] net: arc_emac: support the phy reset for emac driver
Date: Fri, 11 Mar 2016 22:22:00 +0300
Message-ID: <56E31AD8.3060201@cogentembedded.com>
References: <1457693731-6966-1-git-send-email-wxt@rock-chips.com>
 <1457693731-6966-4-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip@lists.infradead.org, keescook@google.com,
	leozwang@google.com, Alexander Kochetkov <al.kochet@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Caesar Wang <wxt@rock-chips.com>, Heiko Stuebner <heiko@sntech.de>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:35758 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbcCKTWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 14:22:05 -0500
Received: by mail-lb0-f172.google.com with SMTP id bc4so168470091lbc.2
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 11:22:03 -0800 (PST)
In-Reply-To: <1457693731-6966-4-git-send-email-wxt@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2016 01:55 PM, Caesar Wang wrote:

> This patch adds to support the emac phy reset.
>
> 1) phy-reset-gpios:
> The phy-reset-gpios is an optional property for arc emac device tree boot.
> Change the binding document to match the driver code.
>
> 2) phy-reset-duration:
> Different boards may require different phy reset duration. Add property
> phy-reset-duration for device tree probe, so that the boards that need
> a longer reset duration can specify it in their device tree.
>
> 3) phy-reset-active-high:
> We need that for a custom hardware that needs the reverse reset sequence.

    What concerns me the most about the existing (and suggested) PHY reset 
related props is that they are located in the MAC device node while not having 
*anything* to do with the MAC at all! These props actually belong to the PHY 
nodes, and I'm currently looking into how to handle them there, where they 
belong...

> Of course, this patch will fix the issue on
> https://patchwork.kernel.org/patch/8186801/.
>
> In some cases, the emac couldn't work if you don't have reset the phy.
> Let's add it to happy work.
>
> Signed-off-by: Caesar Wang <wxt@rock-chips.com>

[...]

MBR, Sergei
