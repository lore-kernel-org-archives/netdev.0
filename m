From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Keep kernel coding style rule of hfs-s+/sp source
Date: Wed, 01 Feb 2012 02:06:02 -0500 (EST)
Message-ID: <20120201.020602.131240058939599710.davem@davemloft.net>
References: <1328079593-19197-1-git-send-email-geunsik.lim@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, lucas.demarchi@profusion.mobi,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geunsik.lim@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328079593-19197-1-git-send-email-geunsik.lim@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geunsik Lim <geunsik.lim@gmail.com>
Date: Wed,  1 Feb 2012 15:59:53 +0900

> Modified for kernel coding style rule of hfs-s+/sp device driver .
> . reference: ./Documentation/CodingStyle
> 
> ex)
> 60 Don't put multiple statements on a single line unless you have
> 61 something to hide:
> 62
> 63         if (condition) do_this;
> 64           do_something_everytime;
> 
> Signed-off-by: Geunsik Lim <geunsik.lim@samsung.com>

This was probably there to eliminate compiler warnings or avoid the
code being eliminated completely, because the result of the register
read is unused.

Have you verified that neither is the case here?

To be honest I very strongly dislike patches like this.  You're
patching a driver that very few people use, and changes like this can
only risk possible regressions that will be hard to notice and it's
not like people scour over this driver often and thus will be upset by
frequently seeing some minor coding style infraction.

I'm not applying this patch.
