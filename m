From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 17:44:38 -0700 (PDT)
Message-ID: <20060420.174438.15249396.davem@davemloft.net>
References: <20060420213305.GK26746@pb15.lixom.net>
	<c0a09e5c0604201514x16490b13v68644a24078b99de@mail.gmail.com>
	<20060420233343.GL26746@pb15.lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36542
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932186AbWDUAou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 20:44:50 -0400
To: olof@lixom.net
In-Reply-To: <20060420233343.GL26746@pb15.lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Thu, 20 Apr 2006 18:33:43 -0500

> On Thu, Apr 20, 2006 at 03:14:15PM -0700, Andrew Grover wrote:
> > In
> > addition, there may be workloads (file serving? backup?) where we
> > could do a skb->page-in-page-cache copy and avoid cache pollution?
> 
> Yes, NFS is probably a prime example of where most of the data isn't
> looked at; just written to disk. I'm not sure how well-optimized the
> receive path is there already w.r.t. avoiding copying though. I don't
> remember seeing memcpy and friends being high on the profile when I
> looked at SPECsfs last.

If that makes sense then the cpu copy can be made to use non-temporal
stores.
