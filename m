From: Dave Jones <davej@redhat.com>
Subject: Re: GPF in skb_flow_dissect
Date: Thu, 13 Dec 2012 10:05:45 -0500
Message-ID: <20121213150545.GA26819@redhat.com>
References: <20121213041644.GB1611@redhat.com>
 <1355376177.12271.244.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15378 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755716Ab2LMPFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 10:05:50 -0500
Content-Disposition: inline
In-Reply-To: <1355376177.12271.244.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 12, 2012 at 09:22:57PM -0800, Eric Dumazet wrote:

 > Yes, commit 7694a3acc55a7 added this bug
 > 
 > Its illegal to use skb after call to netif_rx_ni(skb);
 > 
 > I would try following patch.

Looks like it does the right thing.  Thanks Eric.

	Dave
