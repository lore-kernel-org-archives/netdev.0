From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: WAN: Remove dead code from wanmain.c, CONFIG_WANPIPE_MULTPPP doesn't exist
Date: Wed, 09 Jul 2008 22:43:37 +0200
Message-ID: <m3y74aiy9y.fsf@maximus.localdomain>
References: <m3r6ac3xs8.fsf@maximus.localdomain>
	<20080709144432.GD31126@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from OSB1387.piap.pl ([195.187.100.11]:59592 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753050AbYGIUno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2008 16:43:44 -0400
In-Reply-To: <20080709144432.GD31126@csclub.uwaterloo.ca> (Lennart Sorensen's message of "Wed\, 9 Jul 2008 10\:44\:32 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lsorense@csclub.uwaterloo.ca (Lennart Sorensen) writes:

>> Remove dead code from wanmain.c, CONFIG_WANPIPE_MULTPPP doesn't exist
>
> Does anyone use this ancient code anymore?  Sangoma has been maintaining
> their drivers out of tree for years now and the leftover bits (from 2.2
> or 2.4 days) really isn't interesting anymore as far as I can tell.
> Maybe removal entirely is the correct clean up method.

It seems Cyclades Cyclom 2X (ISA only?) cards use the wanpipe/wanrouter
thing for X.25. I don't know exact status, though.
-- 
Krzysztof Halasa
