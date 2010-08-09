From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next] net:  Provide details on watchdog timeout.
Date: Mon, 9 Aug 2010 15:28:20 -0400
Message-ID: <20100809152820.26dbffc1@s6510>
References: <1281381401-5554-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41173 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753381Ab0HIT2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Aug 2010 15:28:23 -0400
In-Reply-To: <1281381401-5554-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  9 Aug 2010 12:16:41 -0700
Ben Greear <greearb@candelatech.com> wrote:

> This also makes it printed under net_ratelimit instead
> of WARN_ON_ONCE.  The backtrace never helped me much.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
>

Please don't remove the WARN_ because it is used by oops.kernel.org
automated tracking.
