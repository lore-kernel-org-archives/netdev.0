From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Fri, 27 Sep 2002 20:55:20 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209271655.UAA21558@sex.inr.ac.ru>
References: <Pine.LNX.4.44.0209271918090.2895-100000@netcore.fi>
Mime-Version: 1.0
Cc: yoshfuji@linux-ipv6.ORG, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi (Pekka Savola)
In-Reply-To: <Pine.LNX.4.44.0209271918090.2895-100000@netcore.fi> from "Pekka Savola" at Sep 27, 2 07:28:43 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> But you agree that a new selection is important, I think?

It is the thing which would be silly to disagree, people want this. :-)

I do not want bogus implementation blocking attempts to select address
for O(1) time.

> If caching was implemented I guess it would be triggered by:

It is just cached in routes like IP makes this. There is nothing sophisticated
there, the logic is aligned to logic of routing cache.

Alexey
