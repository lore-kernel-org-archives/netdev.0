From: David Miller <davem@davemloft.net>
Subject: Re: why does tcp_v[46]_conn_request not inc MIB stats
Date: Mon, 17 Sep 2007 11:26:50 -0700 (PDT)
Message-ID: <20070917.112650.28789345.davem@davemloft.net>
References: <46E5900A.3010009@hp.com>
	<20070914.201034.38702610.davem@davemloft.net>
	<46EEC3B1.4@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53312
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753017AbXIQS0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 14:26:53 -0400
In-Reply-To: <46EEC3B1.4@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm rebasing a 500 patch tree which has tons of merge conflicts today,
so I lack the time to answer your question.

Suffice it to say you could do a little bit of legwork to figure out
the answer by researching inet_csk_reqsk_queue_is_full() and
determining what sets the state tested by that function.

But you typically don't do this, you always push the queries back
instead of figuring it out yourself, and that doesn't scale.

It can't be all me folks, people have to be as self-sufficient as
possible in order for the work to be distributed properly.

