From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Wed, 09 Aug 2006 17:01:18 -0700 (PDT)
Message-ID: <20060809.170118.116356057.davem@davemloft.net>
References: <1155132440.12225.70.camel@twins>
	<20060809161816.GA14627@postel.suug.ch>
	<1155140394.12225.88.camel@twins>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, phillips@google.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58500
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751375AbWHJABc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 20:01:32 -0400
To: a.p.zijlstra@chello.nl
In-Reply-To: <1155140394.12225.88.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 09 Aug 2006 18:19:54 +0200

> disregards this part from -v2 then :-(

And please don't do arbitrary cleanups in your patches like
how you reformatted all of the NETIF_F_* macro values.

Do things like that as a seperate change in your set of
patches so it's easier for people to review your work.
