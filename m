From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Mon, 12 Feb 2007 12:47:34 -0800 (PST)
Message-ID: <20070212.124734.07455258.davem@davemloft.net>
References: <5640c7e00702121213p1430891el76e259aacd517c4a@mail.gmail.com>
	<20070212.123240.21597176.davem@davemloft.net>
	<20070212123713.1e8efb0d@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, baruch@ev-en.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41693
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965336AbXBLUrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 15:47:36 -0500
In-Reply-To: <20070212123713.1e8efb0d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 12 Feb 2007 12:37:13 -0800

> My patches weren't reactionary. Going to pure old Reno is reactionary.
> It was more looking at the state of the code on the flight back
> and cleaning house. Others were/are reactionary. 

Ok.

The only patch I have a real problem with is the DEFAULT_*
removals, the choices are frankly arbitrary.

Vegas is buggy, that's nice, why don't we simply fix the
bugs in our implementation?

Westwood is very conservative, frankly, and I therefore see
no reason it cannot be offered as a default either.

HTCP doesn't do anything earth shattering either.

I think the whole suite of algorithms in that list are
reasonable.

And even re-reading your patch, you're messing with the
DEFAULT_* setting for the case where the user selected
TCP_CONG_ADVANCED.

I think TCP_CONG_ADVANCED implies an intention by the user,
and if he wants to choose one of those listed as a default
why should we stop them?

The distributions take the default we recommend, and that's
all that matters for wide deployment.

> I push the problem back in their court: "Why do you not have a process
> that causes consensus?" IETF has done nothing to create any incentive
> for long term cooperation.

Yep, this is a good point.

> Do I need to dig out the "Why Reno sucks" graphs?

Hehe :-)
