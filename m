From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ieee802154: Fix oops during ieee802154_sock_ioctl
Date: Mon, 26 Apr 2010 11:20:56 -0700 (PDT)
Message-ID: <20100426.112056.48506797.davem@davemloft.net>
References: <1272293202-11712-1-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stefan@datenfreihafen.org
To: dbaryshkov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272293202-11712-1-git-send-email-dbaryshkov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Mon, 26 Apr 2010 18:46:42 +0400

> From: Stefan Schmidt <stefan@datenfreihafen.org>
> 
> Trying to run izlisten (from lowpan-tools tests) on a device that does not
> exists I got the oops below. The problem is that we are using get_dev_by_name
> without checking if we really get a device back. We don't in this case and
> writing to dev->type generates this oops.
> 
> [Oops code removed by Dmitry Eremin-Solenikov]
> 
> If possible this patch should be applied to the current -rc fixes branch.
> 
> Signed-off-by: Stefan Schmidt <stefan@datenfreihafen.org>
> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>

Applied, and queued up for -stable too, thanks guys.
