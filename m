From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cassini: use nested lock annotation
Date: Fri, 09 May 2014 16:34:31 -0400 (EDT)
Message-ID: <20140509.163431.2271871004754320745.davem@davemloft.net>
References: <1399590437-5548-1-git-send-email-emilgoode@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jg1.han@samsung.com, jeffrey.t.kirsher@intel.com,
	ben@decadent.org.uk, arend@broadcom.com, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: emilgoode@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399590437-5548-1-git-send-email-emilgoode@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Emil Goode <emilgoode@gmail.com>
Date: Fri,  9 May 2014 01:07:17 +0200

> In the cas_lock_tx function we acquire multiple locks in a loop and
> need to use nested lock annotation to prevent lockdep warnings.
> 
> Reported-by: Meelis Roos <mroos@linux.ee>
> Signed-off-by: Emil Goode <emilgoode@gmail.com>

Applied, thanks.
