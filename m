From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] atm: iphase: return -ENOMEM instead of -1 in case
 of failed kmalloc()
Date: Mon, 12 Oct 2015 19:56:48 -0700 (PDT)
Message-ID: <20151012.195648.1985012794848944824.davem@davemloft.net>
References: <1444506439-10414-1-git-send-email-theidsieck@leenox.de>
	<1444506439-10414-2-git-send-email-theidsieck@leenox.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: theidsieck@leenox.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444506439-10414-2-git-send-email-theidsieck@leenox.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tillmann Heidsieck <theidsieck@leenox.de>
Date: Sat, 10 Oct 2015 21:47:18 +0200

> Smatch complains about returning hard coded error codes, silence this
> warning.
> 
> drivers/atm/iphase.c:115 ia_enque_rtn_q() warn: returning -1 instead of -ENOMEM is sloppy
> 
> Signed-off-by: Tillmann Heidsieck <theidsieck@leenox.de>

Applied to net-next.
