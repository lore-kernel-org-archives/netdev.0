From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/3] macvtap: simplify usage of tap_features
Date: Tue, 20 Aug 2013 13:09:36 -0700 (PDT)
Message-ID: <20130820.130936.1537489187268660011.davem@davemloft.net>
References: <1376681102-19753-1-git-send-email-vyasevic@redhat.com>
	<1376681102-19753-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938Ab3HTUJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 16:09:37 -0400
In-Reply-To: <1376681102-19753-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Fri, 16 Aug 2013 15:25:00 -0400

> In macvtap, tap_features specific the features of that the user
> has specified via ioctl().  If we treat macvtap as a macvlan+tap
> then we could all the tap a pseudo-device and give it other features
> like SG and GSO.  Then we can stop using the features of lower
> device (macvlan) when forwarding the traffic the tap.
> 
> This solves the issue of possible checksum offload mismatch between
> tap feature and macvlan features.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied.
