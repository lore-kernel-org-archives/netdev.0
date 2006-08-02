From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 20/23] [PATCH] [XFRM] POLICY: sub policy support.
Date: Wed, 2 Aug 2006 12:04:31 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608021152060.21751@d.namei>
References: <1154165451738-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:13235 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932085AbWHBQEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 12:04:33 -0400
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <1154165451738-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 29 Jul 2006, Masahide NAKAMURA wrote:

> Sub policy is introduced. Main and sub policy are applied the same flow.
> (Policy that current kernel uses is named as main.)
> It is required another transformation policy management to keep IPsec
> and Mobile IPv6 lives separate.
> Policy which lives shorter time in kernel should be a sub i.e. normally
> main is for IPsec and sub is for Mobile IPv6.
> (Such usage as two IPsec policies on different database can be used, too.)

Why can't IPSec & MIP transforms be bundled on the same policy?

Or, perhaps a different approach is needed, where the disposition of a 
policy can be to re-submit a packet for another policy match after the 
current bundle has been traversed (something like NF_REPEAT).


- James
-- 
James Morris
<jmorris@namei.org>
