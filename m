From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next] genetlink: Fix generic netlink family
 unregister
Date: Sat, 29 Oct 2016 01:24:43 +0200
Message-ID: <1477697083.4220.3.camel@sipsolutions.net>
References: <1477695701-1147-1-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Pravin B Shelar <pshelar@ovn.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59430 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753245AbcJ1XYq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 19:24:46 -0400
In-Reply-To: <1477695701-1147-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-10-28 at 16:01 -0700, Pravin B Shelar wrote:
> This patch fixes a typo in unregister operation.
> 
> Following crash is fixed by this patch. It can be easily reproduced
> by repeating modprobe and rmmod module that uses genetlink.

Yikes, I ran all my tests in VMs and forgot this wasn't even executed.
Sorry about that!

Reviewed-by: Johannes Berg <johannes@sipsolutions.net>

johannes
