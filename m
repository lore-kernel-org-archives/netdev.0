From: Baruch Even <baruch@ev-en.org>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Mon, 12 Feb 2007 21:11:01 +0200
Message-ID: <20070212191101.GP25760@galon.ev-en.org>
References: <20070212160317.545906075@linux-foundation.org> <20070212160336.681729431@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:58242
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965313AbXBLTLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 14:11:04 -0500
Content-Disposition: inline
In-Reply-To: <20070212160336.681729431@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Stephen Hemminger <shemminger@linux-foundation.org> [070212 18:04]:
> The TCP Vegas implementation is buggy, and BIC is too agressive
> so they should not be in the default list. Westwood is okay, but
> not well tested.

Since no one really agrees on the relative merits and problems of the
different algorithms and since the users themselves dont know, dont care
and have no clue on what should be the correct behaviour to report bugs
(see the old bic bugs, the htcp bugs, the recent sack bugs) I would
suggest to avoid making the whole internet a guinea pig and get back to
reno. If someone really needs to push high BDP flows he should test it
himself and choose what works for his kernel at the time.

For myself and anyone who asks me I recommend to set the default to
reno. For the few who really need high speed flows, they should test
kernel and protocol combination.

Baruch
