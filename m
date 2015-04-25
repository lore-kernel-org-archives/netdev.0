From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 00/21] ARCNET: Defibrillation
Date: Fri, 24 Apr 2015 21:52:37 -0700
Message-ID: <1429937557.23327.57.camel@perches.com>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
	 <1429901273.23327.5.camel@perches.com> <553AB241.3080004@pengutronix.de>
	 <20150424.235853.1997287895150693202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, m.grzeschik@pengutronix.de,
	netdev@vger.kernel.org, kernel@pengutronix.de,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150424.235853.1997287895150693202.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-04-24 at 23:58 -0400, David Miller wrote:
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Fri, 24 Apr 2015 23:14:41 +0200
> > On 04/24/2015 08:47 PM, Joe Perches wrote:
> >> On Fri, 2015-04-24 at 19:20 +0200, Michael Grzeschik wrote:
> >>> This patch series tries to reanimate the ARCNET hardware layer to be
> >>> somehow readable and maintainable again. It includes a lot of cleanup
> >>> patches. It also adds some fixes which leads the layer to become usable
> >>> again. And as a special treatment it adds more features like correct
> >>> loading and unloading of the com20020 card.
> >> Wow.  Good for you, but why?  Does anyone still use these?
> > Yes, there are parts of the industry where "old" machines are
> > retrofitted with new hardware...and a lot of these machines still talk
> > ARCNET :)
> 
> But the real issue is, this layer is development wise in the same
> category as the IDE layer.
> 
> Any non-trivial change is nothing but pure risk, especially given the
> low level of test coverage the code gets.
> 
> So I really only want to see the most critical obvious bug fixes
> submitted for this layer and drivers.
> 
> And no I will not accept an argument stating that you have to
> restructure and clean this code up in order to fix the bugs.  That's
> bogus.

I think that arcnet is a fairly simple protocol.

Given the current state of the code, if someone wants to
make the code better, it might be better to wholesale
replace what's there instead of incrementally modifying it.

It's not that difficult to make what's there style cleaner
though.  Most if it is trivial sed style replacements.

Dunno. It doesn't look like that big a job actually, but I
don't use it nor could I do testing on actual hardware.

If pengutronix wants help, I probably could.
