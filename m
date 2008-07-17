From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2: no error message when link up command fails.
Date: Thu, 17 Jul 2008 09:59:45 +0000
Message-ID: <20080717095945.GA4327@ff.dom.local>
References: <487F104E.6070003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Henriksson <andreas@fatal.se>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	stephen.hemminger@vyatta.com, 489340@bugs.debian.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:29553 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901AbYGQJyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 05:54:47 -0400
Received: by fg-out-1718.google.com with SMTP id 19so2586497fgg.17
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 02:54:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <487F104E.6070003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-2008 11:26, Patrick McHardy wrote:
...
> rtnetlink: propagate error from dev_change_flags in do_setlink()
> 
> Andreas Henriksson <andreas@fatal.se> reported that

+ Johannes Berg reported that

> unlike ifconfig,
> iproute doesn't report an error when setting an interface up fails.
> 
> Propagate the return value from dev_change_flags() to fix this.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Jarek P.
