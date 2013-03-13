From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/6] GRE: Use RTNL for atomic protocol
 registration.
Date: Wed, 13 Mar 2013 15:57:43 -0700
Message-ID: <20130313155743.641adada@nehalam.linuxnetplumber.net>
References: <1363214907-3257-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:60874 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932534Ab3CMW5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:57:48 -0400
Received: by mail-pb0-f41.google.com with SMTP id um15so1496785pbc.28
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 15:57:47 -0700 (PDT)
In-Reply-To: <1363214907-3257-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Mar 2013 15:48:27 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> Currently gre demultiplexer uses its own spin-lock. We should
> rather RTNL lock.
> 
> Suggested-by: Stephen Hemminger <--cc stephen@networkplumber.org>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Contradicting myself :-)
This does have added safety but some people eventually want to get rid
of the big network lock. That said, it makes sense that you would need a
supersized lock when playing with multiple devices.
