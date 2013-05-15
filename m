From: David Miller <davem@davemloft.net>
Subject: Re: [Patch iproute2] vxlan: use 8472 as default dst port
Date: Wed, 15 May 2013 13:23:34 -0700 (PDT)
Message-ID: <20130515.132334.1947188064480328606.davem@davemloft.net>
References: <20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
	<OFF100C7ED.6500FAB3-ON85257B6C.005DCF7C-85257B6C.005F309B@us.ibm.com>
	<20130515104308.5de3e852@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, amwang@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932623Ab3EOUXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 16:23:35 -0400
In-Reply-To: <20130515104308.5de3e852@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 15 May 2013 10:43:08 -0700

> I want all new users to get the IANA port without asking.
> Old users with existing nets have to force the port to the one they were using.

That's breaking things for existing users, you can't do it.
