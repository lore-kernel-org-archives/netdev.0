From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kzalloc with swapped params in l2tp_dfs_seq_open
Date: Mon, 01 Nov 2010 06:56:28 -0700 (PDT)
Message-ID: <20101101.065628.104045417.davem@davemloft.net>
References: <20101031172603.GB16459@gallifrey>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jchapman@katalix.com,
	netdev@vger.kernel.org
To: linux@treblig.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38958
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756390Ab0KAN4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 09:56:05 -0400
In-Reply-To: <20101031172603.GB16459@gallifrey>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dr. David Alan Gilbert" <linux@treblig.org>
Date: Sun, 31 Oct 2010 17:26:03 +0000

> Hi,
>   'sparse' spotted that the parameters to kzalloc in l2tp_dfs_seq_open
> were swapped.
> 
> Tested on current git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
> at 1792f17b7210280a3d7ff29da9614ba779cfcedb  build, boots and I can see that directory,
> but there again I could see /sys/kernel/debug/l2tp with it swapped; I don't have
> any l2tp in use.
> 
> Signed-off-by: Dr. David Alan Gilbert <linux@treblig.org>

Applied, thank you.
