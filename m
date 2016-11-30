From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm_user: fix return value from xfrm_user_rcv_msg
Date: Wed, 30 Nov 2016 13:15:30 +0100
Message-ID: <20161130121530.GV3541@gauss.secunet.com>
References: <1480414141-17801-1-git-send-email-yi.zhao@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <fan.du@intel.com>
To: Yi Zhao <yi.zhao@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:48184 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753106AbcK3MPf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 07:15:35 -0500
Content-Disposition: inline
In-Reply-To: <1480414141-17801-1-git-send-email-yi.zhao@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 06:09:01PM +0800, Yi Zhao wrote:
> It doesn't support to run 32bit 'ip' to set xfrm objdect on 64bit host.
> But the return value is unknown for user program:
> 
> ip xfrm policy list
> RTNETLINK answers: Unknown error 524
> 
> Replace ENOTSUPP with EOPNOTSUPP:
> 
> ip xfrm policy list
> RTNETLINK answers: Operation not supported
> 
> Signed-off-by: Yi Zhao <yi.zhao@windriver.com>

Applied to the ipsec tree, thanks!
