From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] vxlan: fix unused variable warning
Date: Thu, 15 Dec 2016 10:17:54 +0100
Message-ID: <20161215101754.51fa39d6@griffin>
References: <20161214124355.7da92ff3@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59756 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751214AbcLOJR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 04:17:57 -0500
In-Reply-To: <20161214124355.7da92ff3@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Dec 2016 12:43:55 -0800, Stephen Hemminger wrote:
> Fixes commit 4528520d315ac1 ("vxlan: add ipv6 proxy support")

Wrong hash, it was commit f564f45c4518. And that commit actually did
use saddr, the actual commit that is being fixed is 4b29dba9c085
("vxlan: fix nonfunctional neigh_reduce()"). Also, please use the
standard Fixes: line when resubmitting this.

The patch itself looks good.

Thanks,

 Jiri
