From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/2] BQL support and fix for a regression issue
Date: Thu, 22 Sep 2016 06:12:16 -0700
Message-ID: <1474549936.23058.98.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474535121-13958-1-git-send-email-sunil.kovvuri@gmail.com>
         <20160922.082540.992436214283504080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sunil.kovvuri@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        sgoutham@cavium.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35190 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752016AbcIVNMT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 09:12:19 -0400
In-Reply-To: <20160922.082540.992436214283504080.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-22 at 08:25 -0400, David Miller wrote:
> From: sunil.kovvuri@gmail.com
> Date: Thu, 22 Sep 2016 14:35:19 +0530
> 
> > From: Sunil Goutham <sgoutham@cavium.com>
> > 
> > These patches add byte queue limit support and also fixes a regression
> > issue introduced by commit
> > 'net: thunderx: Use netdev's name for naming VF's interrupts'
> 
> The correct way to refer to commits when you fix a bug is
> to use the "Fixes: " tag right before the signoffs and ACKs.
> 
> The correct form is:
> 
> Fixes: $SHA1_ID ("Commit header line.")
> 
> You'll see this in many other netdev commits.

Thanks a lot David for this enforcement, it really helps bug tracking
and backports

Note that the $SHA1_ID should be truncated to 12 first chars.

Refer to Documentation/SubmittingPatches around line 191 for more
details.
