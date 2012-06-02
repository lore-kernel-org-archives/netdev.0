From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: IO_PAGE_FAULT & netdev watchdog
Date: Sat, 2 Jun 2012 12:56:45 +0200
Message-ID: <20120602105645.GA28769@electric-eye.fr.zoreil.com>
References: <201205312331.06623.plr.vincent@gmail.com> <20120601125949.GA11973@electric-eye.fr.zoreil.com> <201206021108.53551.plr.vincent@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vincent Pelletier <plr.vincent@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60344 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966282Ab2FBLFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 07:05:18 -0400
Content-Disposition: inline
In-Reply-To: <201206021108.53551.plr.vincent@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vincent Pelletier <plr.vincent@gmail.com> :
[...]
> So I went with 3.3.7, and patch failed to apply, at least partly because
> 3.3.7 lacks "r8169: fix early queue wake-up."[1].

And partly because the patch I sent included its content in the commit
message as well. :o/

> I solved the conflicts manually, but I'm not sure of the result. Could you
> confirm attached patch might give expected result ?

Yes.

> Or should I stick to 3.4 and only test inlined patch ?

If the inlined patch makes a difference, you should see it with 3.4.

My life is a bit easier when you work somewhere in the main branch
(or in davem's -next but it is not relevant for regression fixes).

-- 
Ueimor
