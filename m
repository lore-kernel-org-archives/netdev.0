From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openvswitch: fix sw_flow_key alignment
Date: Sat, 31 Aug 2013 00:16:50 -0400 (EDT)
Message-ID: <20130831.001650.130549489746201651.davem@davemloft.net>
References: <CAEP_g=9y-HeG0vHS2v-dk7eDp=T0denddykDO3TJtk4UJ062Mg@mail.gmail.com>
	<20130830.144211.1550393719904034493.davem@davemloft.net>
	<CAEP_g=-zgaKot6f5w=sqVjOauT9OtSd1sjrJSwc5AC7xR1s99g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: azhou@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013Ab3HaEQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 00:16:53 -0400
In-Reply-To: <CAEP_g=-zgaKot6f5w=sqVjOauT9OtSd1sjrJSwc5AC7xR1s99g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 30 Aug 2013 16:20:25 -0700

> I looked through the struct definition and I think that the idea of
> manually padding as Geert did in his patch will be difficult to
> maintain over time (and actually there are a few that he missed) since
> there are a number of different structs/unions contained in there.

You have to be mindful of the gaps and wasted space for performance
reasons anyways.
