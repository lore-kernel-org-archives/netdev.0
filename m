From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netns: Add network namespace argument in
 rt6_fill_node() and ipv6_dev_get_saddr()
Date: Sun, 17 Aug 2008 15:35:26 -0700 (PDT)
Message-ID: <20080817.153526.109132408.davem@davemloft.net>
References: <48A48722.3050509@hp.com>
	<48A758F0.60009@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, containers@lists.osdl.org,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44755
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752062AbYHQWf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 18:35:26 -0400
In-Reply-To: <48A758F0.60009@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sun, 17 Aug 2008 00:47:12 +0200

> The approach looks correct except with the network namespace passed as 
> parameter, it must never be NULL.

You're reviewing the patches that Brian retracted, we added a different
version of these fixes in the end.
