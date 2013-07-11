From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gre: Fix MTU sizing check for gretap tunnels
Date: Thu, 11 Jul 2013 16:30:49 -0700 (PDT)
Message-ID: <20130711.163049.2156289666282417262.davem@davemloft.net>
References: <CALnjE+p3tqNO9Fbn=+LLtL8VvfvSQyOLDZoFRvGFTXgJzHKqhQ@mail.gmail.com>
	<1373582702.4600.85.camel@edumazet-glaptop>
	<CALnjE+oXbT+J01A-9GRxAAVuANaVA6ifF5_oc6ZSWRY2TTVUBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755738Ab3GKXau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 19:30:50 -0400
In-Reply-To: <CALnjE+oXbT+J01A-9GRxAAVuANaVA6ifF5_oc6ZSWRY2TTVUBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Thu, 11 Jul 2013 16:19:17 -0700

> gre is been using dev->hard_header_len rather than
> rt_dev->hard_header_len for long time which does not look right.

I noticed this as well.

I would suggest implementing these calculations in small discrete
helper functions, with big comments.  Right now the code is hard
to understand even by experts.
