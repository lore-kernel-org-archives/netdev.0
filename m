From: David Miller <davem@davemloft.net>
Subject: Re: Linux stack performance drop (TCP and UDP) in 3.10 kernel in
 routed scenario
Date: Wed, 04 Jun 2014 12:18:19 -0700 (PDT)
Message-ID: <20140604.121819.2149110045488849780.davem@davemloft.net>
References: <CAJMXqXZQ_S27LCZNJDjcQ9jy2qyJ0UT2nk+wdZOTQep+5rQZhQ@mail.gmail.com>
	<CAJMXqXaf6P=F4+jLhRFrv9GTRK6K9h5boSgyVCS7e9C31a_YzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.ne
To: suprasad.desai@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbaFDTSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 15:18:23 -0400
In-Reply-To: <CAJMXqXaf6P=F4+jLhRFrv9GTRK6K9h5boSgyVCS7e9C31a_YzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suprasad Mutalik Desai <suprasad.desai@gmail.com>
Date: Wed, 4 Jun 2014 14:34:10 +0530

> I guess plain routing scenario was NOT thought through while removing
> the routing cache code.

It is exactly the scenerio that was considered.

The routing cache was susceptible to trivial denial of service
attacks, it therefore had to be removed.

It also scaled poorly with large numbers of active flows.
