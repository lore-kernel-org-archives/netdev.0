From: David Miller <davem@davemloft.net>
Subject: Re: [Patch iproute2] vxlan: use 8472 as default dst port
Date: Wed, 15 May 2013 13:22:13 -0700 (PDT)
Message-ID: <20130515.132213.120685330795916926.davem@davemloft.net>
References: <1368616270-5775-1-git-send-email-amwang@redhat.com>
	<OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com>
	<20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, amwang@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932742Ab3EOUWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 16:22:16 -0400
In-Reply-To: <20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 15 May 2013 09:53:22 -0700

> No. I want all users to get the IANA assigned port unless they specifically
> override it. For compatibility kernel can't change to the IANA value
> but user space needs to nudge users in the correct direction.

You're changing the behavior people get by invoking the tools the way
they were doing so previously.

Therefore, just as we can't change the kernel's default, you really
can't legitimately change iproute2's either.
