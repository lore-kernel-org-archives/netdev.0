From: Damien Wyart <damien.wyart@gmail.com>
Subject: Re: IPv6: Bug in net-next
Date: Wed, 8 Jan 2014 14:54:15 +0100
Message-ID: <20140108135415.GA5561@brouette>
References: <1389187126.20074.YahooMailBasic@web125504.mail.ne1.yahoo.com>
 <1389188139.44648.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: =?iso-8859-1?Q?Fran=E7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhost-v2-m3.nerim-networks.com ([78.40.49.217]:15031 "EHLO
	smtp-delay2.nerim.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932326AbaAHOAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 09:00:07 -0500
Received: from maiev.nerim.net (smtp-153-wednesday.nerim.net [194.79.134.153])
	by smtp-delay2.nerim.net (Postfix) with ESMTP id BB87219CF007
	for <netdev@vger.kernel.org>; Wed,  8 Jan 2014 14:54:39 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1389188139.44648.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > When I execute this code and press Crtl-C, all the IPv6 Link-Layer
> > > addresses are deleted.

> It seems that the valid lifetime and preferred lft are set to 0 sec
> for autoconfigured LLA.

I am also seeing the problem with Linus' up-to-date tree (3.13-rc7+).

On eth0, LLA is not present after boot, as well as ::1 (Host scope) on
the loopback (which causes some daemons to not start properly as they
try to listen on ::1). Manually setting these adresses with ip addr
works, they do not disappear afterwards.

-- 
Damien
