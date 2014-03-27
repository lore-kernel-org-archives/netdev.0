From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: Fix compilation when CONFIG_BNX2X_SRIOV
 is not set
Date: Thu, 27 Mar 2014 10:27:26 -0700
Message-ID: <1395941246.12610.308.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395817589-22890-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, Ariel.Elior@qlogic.com
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:37496 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755469AbaC0R12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 13:27:28 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so3768022pad.14
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 10:27:27 -0700 (PDT)
In-Reply-To: <1395817589-22890-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-26 at 09:06 +0200, Yuval Mintz wrote:
> Commit 370d4a26 "bnx2x: Create workqueue for IOV related tasks" breaks bnx2x
> compilation when CONFIG_BNX2X_SRIOV is not set - "multiple definition of
> `bnx2x_schedule_iov_task'".
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> ---
> Hi Dave,
> 
> Please accept this to net-next as it fixes our latest submission there.

Right I got bitten by this, please David apply ;)

Acked-by: Eric Dumazet <edumazet@google.com>
