From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Mon, 12 Feb 2007 12:32:40 -0800 (PST)
Message-ID: <20070212.123240.21597176.davem@davemloft.net>
References: <20070212160336.681729431@linux-foundation.org>
	<20070212191101.GP25760@galon.ev-en.org>
	<5640c7e00702121213p1430891el76e259aacd517c4a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: baruch@ev-en.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: ian.mcdonald@jandi.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43200
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965377AbXBLUcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 15:32:41 -0500
In-Reply-To: <5640c7e00702121213p1430891el76e259aacd517c4a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 13 Feb 2007 09:13:52 +1300

> Unless of course the papers you saw at PFLDNET showed that Cubic was a
> really good choice and you want to point us to those papers.

I heavily dislike all of these "reactionary" patches from Stephen
after he attended PFDLNET.

If he never went there, none of these patches would have been
proposed.  He went to the sermon and he became converted :-)

We want people to play with this stuff, and they can experiment
regardless of whatever options or even code we put into the kernel.
Every user can muck with the congestion control on their computer
however they want, and THAT'S GOOD!

Sure we indirectly recommend to distribution vendors what to use
by default by the Kconfig defaults we put into the vanilla tree,
and that's fine too.

Even after reading all of the papers, I still think CUBIC or even BIC
by default is not all that controbersal or radical thing to use by
default.

I'm sorry if the researchers and IETF folks don't like this.  Too bad,
get over it.

If you use RENO you're stupid, since performance is going to stink for
absolutely normal connections.  Fact: high BDP pipes are everywhere,
even grandma has one.  So just taking out the best solution we have
for that problem currently because it's not perfect is not the answer.

This is not the internet of 15 years ago, please wake up everyone.
We cannot sit on eggs for 5 years to make sure they hatch perfectly
like was previously possible.

I think the best thing we ever did was create the congestion control
algorithm abstraction and add a bunch of reasonable algorithms, and
then on top of that try to use something modern by default.
