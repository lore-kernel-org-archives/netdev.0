From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Implement a two-level initial RTO as per draft
 RFC 2988bis-02.
Date: Wed, 18 May 2011 22:36:22 -0400 (EDT)
Message-ID: <20110518.223622.1525088601595365235.davem@davemloft.net>
References: <20110518.155200.801089483916944725.davem@davemloft.net>
	<1305771744-83951-1-git-send-email-tsunanet@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, hagen@jauu.net,
	eric.dumazet@gmail.com, alexander.zimmermann@comsys.rwth-aachen.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tsunanet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305771744-83951-1-git-send-email-tsunanet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benoit Sigoure <tsunanet@gmail.com>
Date: Wed, 18 May 2011 19:22:24 -0700

> Prior to this patch, Linux would always use 3 seconds (compile-time
> constant) as the initial RTO.  Draft RFC 2988bis-02 proposes to tune
> this down to 1 second and, in case of a timeout during the TCP 3WHS,
> revert the RTO back up to 3 seconds when data transmission begins.

We just had a discussion where it was determined that changes to
these settings are "network specific" and therefore that if it
is appropriate at all (I'm still not convinced) it is only suitable
as a routing metric.
