From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] tulip: xircom_cb: Convert #ifdef DEBUG
 blocks and enter/leave uses
Date: Mon, 09 May 2011 12:51:46 -0700 (PDT)
Message-ID: <20110509.125146.229755454.davem@davemloft.net>
References: <cover.1304970062.git.joe@perches.com>
	<abc11d127dbde89baf98eaa6c409d89b2a8a5a21.1304970062.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <abc11d127dbde89baf98eaa6c409d89b2a8a5a21.1304970062.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon,  9 May 2011 12:45:20 -0700

> Change the blocks that are guarded by #if DEBUG to
> be #if defined DEBUG && DEBUG > 1 so that pr_debug
> can be used later.
> 
> Remove enter/leave macros and uses.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
