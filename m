From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Mon, 12 Feb 2007 12:34:43 -0800 (PST)
Message-ID: <20070212.123443.85409558.davem@davemloft.net>
References: <20070212191101.GP25760@galon.ev-en.org>
	<5640c7e00702121213p1430891el76e259aacd517c4a@mail.gmail.com>
	<20070212122634.07b3303b@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, baruch@ev-en.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52092
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S964888AbXBLUeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 15:34:44 -0500
In-Reply-To: <20070212122634.07b3303b@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 12 Feb 2007 12:26:34 -0800

> No magic paper. But the impression from multiple talks is that Cubic
> is still doing fine.  Also for non high speed flows, it really doesn't matter
> because all the loss based congestion controls behave the same.

This last point is important.

Either it's high BDP and it uses the new stuff (and we WANT it to)
or it's not high BDP and it USES RENO!

That's why Baruch's email is totally illogical.

If people don't have high BDP, these algorithms such as CUBIC and BIC
change nothing compared to Reno, they purposely behave precisely the
same.
