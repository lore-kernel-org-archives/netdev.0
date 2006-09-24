From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 02/03] net/bridge: add support for EtherIP devices
Date: Sat, 23 Sep 2006 21:01:12 -0700
Message-ID: <20060923210112.130938ca@localhost.localdomain>
References: <20060923120704.GA32284@zlug.org>
	<20060923121629.GC32284@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:64224 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752100AbWIXEBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2006 00:01:35 -0400
To: Joerg Roedel <joro-lkml@zlug.org>
In-Reply-To: <20060923121629.GC32284@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 23 Sep 2006 14:16:29 +0200
Joerg Roedel <joro-lkml@zlug.org> wrote:

> This patch changes the device check in the bridge code to allow EtherIP
> devices to be added.
> 
> Signed-off-by: Joerg Roedel <joro-lkml@zlug.org>

If the device looks like a duck (Ethernet), then why does it need
a separate ARP type.  There are other tools that might work without
modification if it just fully pretended to be an ether device.
