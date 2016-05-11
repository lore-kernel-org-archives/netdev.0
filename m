From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Wed, 11 May 2016 16:10:40 +0200
Message-ID: <20160511161040.06bfe867@griffin>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
	<1462347393-22354-5-git-send-email-simon.horman@netronome.com>
	<20160506113504.77a9504e@griffin>
	<20160509081818.GB4470@vergenet.net>
	<20160510140618.3ad4a35f@griffin>
	<20160511032812.GC24805@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32780 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751397AbcEKOKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2016 10:10:43 -0400
In-Reply-To: <20160511032812.GC24805@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 May 2016 12:28:14 +0900, Simon Horman wrote:
> I think that at this stage I would prefer to prohibit push_eth() acting
> on a packet which already has an ethernet header. Indeed that is what
> my patch-set already does in its modifications of __ovs_nla_copy_actions().
> 
> The reason that I lean towards prohibiting this is that I do not
> have an easy way to exercise this case within the current patch-set.
> And thus this extra complexity seems well suited to being handled handled
> incrementally as further work.

Works for me. I don't see any real usage for multiple Ethernet headers.

Thanks!

 Jiri
