From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] rocker: silence shift wrapping warning
Date: Fri, 27 Feb 2015 15:59:25 -0500 (EST)
Message-ID: <20150227.155925.1726922130874367959.davem@davemloft.net>
References: <20150225133612.GV19745@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150225133612.GV19745@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 25 Feb 2015 16:36:12 +0300

> "val" is declared as a u64 so static checkers complain that this shift
> can wrap.  I don't have the hardware but probably it's doesn't have over
> 31 ports.  Still we may as well silence the warning even if it's not a
> real bug.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
 
Applied.
