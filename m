From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: testing crazy stuff with iproute2
Date: Thu, 27 Dec 2007 23:54:55 +0100
Message-ID: <20071227225455.GA6672@ami.dom.local>
References: <20071226045037.M75814@visp.net.lb> <4774146D.1030502@gmail.com> <20071227212405.M87764@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:18446 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbXL0Wur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 17:50:47 -0500
Received: by fk-out-0910.google.com with SMTP id z23so3557783fkz.5
        for <netdev@vger.kernel.org>; Thu, 27 Dec 2007 14:50:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071227212405.M87764@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 27, 2007 at 11:25:53PM +0200, Denys Fedoryshchenko wrote:
> I will try to talk in lartc, about HTB i wrote another mail...
> It is not acting as TBF with burst, it is even acting weird. Probably it is 
> bug, when traffic get "blocked" cause of burst.

HTB was probably projected to be simple, so it has less knobs than CBQ 
or TBF. But it shouldn't act weird, unless you do weird things...
E.g. what do you expect with 'rate 8bit'? I think, you should firstly
do some tests with different rates without touching cburst or even
quantum: HTB usually uses workable defaults if rates and packet sizes
are within some limits. End at the beginning I think it's better to
always use 'default' parameter with qdisc, and add some class for this
to verify all traffic is filtered as expected. 

> I will try to use lartc, if it is better to not "spam" my stuff here :-)

Maybe you don't believe it, but I really knew much more about properly
setting HTB parameters 2 years ago, when I read lartc or not worse our
local linux networking news group than now - when, this practical
knowledge was mostly erased by some 'useless' inside details.

> I didn't try yet PSPacer yet, as ESFQ things. If it is need i can do that and 
> write feedback. I can use some of them in real environment after some pre-
> testing.

It looked like very interesting, so I'm only a bit curious why so
quiet...

Jarek P.
