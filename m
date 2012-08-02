From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: fix mem leak when command is unknown
Date: Thu, 02 Aug 2012 00:21:07 -0700 (PDT)
Message-ID: <20120802.002107.240245942153879823.davem@davemloft.net>
References: <alpine.LNX.2.00.1207312337590.7100@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1207312337590.7100@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Tue, 31 Jul 2012 23:39:37 +0200 (CEST)

> In bnx2x_mcast_enqueue_cmd() we'll leak the memory allocated to
> 'new_cmd' if we hit the deafault case of the 'switch (cmd)'.
> Add a 'kfree(new_cmd)' to that case to avoid the leak.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied.
