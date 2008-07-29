From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: iproute2 / match / meta bug?
Date: Tue, 29 Jul 2008 11:16:27 +0300
Message-ID: <200807291116.28103.denys@visp.net.lb>
References: <200807290843.29447.denys@visp.net.lb> <200807290925.46731.denys@visp.net.lb> <200807290935.50100.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:33028 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757309AbYG2IQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 04:16:50 -0400
In-Reply-To: <200807290935.50100.denys@visp.net.lb>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that parser broken there (em_meta.c) too.

It won't recognize "quoted"/string parameter. For example:

'meta(dev eq "tap0")' will not work
but 
'meta(dev eq 1234)' will work

and so on... 
example is broken too, there is no more such parameter as indev i guess.

I am trying now to make it understand rt_iif as name, but seems i am stuck with parser, because it doesn't work even with things it must recognize.
And because of my weak programming skills seems it is trivial for someone to fix and implement rt_iif recognition by interface name (using ll_name_to_index i guess?)
, but it's near impossible for me.

Anybody can help? 
If not - i will try to do by myself, but it will take ages.

On Tuesday 29 July 2008, Denys Fedoryshchenko wrote:
> Yes, there is typo seems, i check git also, bug is there.
> No idea how it works with you :-\ Maybe on your arch ULONG_MAX == LONG_MAX


