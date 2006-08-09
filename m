From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Rules and groups
Date: Wed, 9 Aug 2006 11:25:37 +0200
Message-ID: <20060809092537.GV14627@postel.suug.ch>
References: <20060809080139.GA19555@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick Caulfield <patrick@tykepenguin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:27539 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1030607AbWHIJZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 05:25:17 -0400
To: Steven Whitehouse <steve@chygwyn.com>
Content-Disposition: inline
In-Reply-To: <20060809080139.GA19555@souterrain.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Steven Whitehouse <steve@chygwyn.com> 2006-08-09 09:01
> With your new protocol independent rules code, I see that there is an
> entry in struct fib_rules_ops for a netlink group for notification of
> rule changes. For whatever reason (historical I guess) DECnet has never
> had a nl group assigned for this, so I'm left with two choices when moving
> the code over to ues your new scheme.
> 
> Either I could send a patch to put the content of notify_rule_change()
> conditional on nlgroup being non-zero, or I could assign a suitable
> group for DECnet rule changes. I'm leaning towards the latter as the
> best solution, so that at least it matches up with the other protocols.

Absolutely, notification for DECnet rule changes would be nice to have.
