From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: neterion: vxge: vxge-traffic.c: fix for a
 potential NULL pointer dereference
Date: Mon, 18 Feb 2013 14:45:54 -0500 (EST)
Message-ID: <20130218.144554.1124057233943399415.davem@davemloft.net>
References: <1361037394-14731-1-git-send-email-gmate.amit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: gmate.amit@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361037394-14731-1-git-send-email-gmate.amit@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kumar Amit Mehta <gmate.amit@gmail.com>
Date: Sat, 16 Feb 2013 09:56:34 -0800

> fix for a potential NULL pointer dereference and removal of a redundant
> assignment operation. Found using smatch.
> 
> Signed-off-by: Kumar Amit Mehta <gmate.amit@gmail.com>

Obviously whoever wrote this code intended for ALARM_CLEARED
and EVENT_UNKNOWN events to not be logged.

But you're changing that.

I'm not applying this patch, sorry.
