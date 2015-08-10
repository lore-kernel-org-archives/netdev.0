From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Filtered data on Rx descriptor status context
Date: Mon, 10 Aug 2015 21:24:59 +0200
Message-ID: <20150810192459.GA5361@electric-eye.fr.zoreil.com>
References: <1439121449-1835-1-git-send-email-corcodel.marian@gmail.com>
 <20150809220955.GA12564@electric-eye.fr.zoreil.com>
 <CAGg4U=GQwTUcZhNv-mJPZ8JxO4JSLw_1UwQSorYfCv38u1uuUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marian Corcodel <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55618 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754644AbbHJTZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 15:25:19 -0400
Content-Disposition: inline
In-Reply-To: <CAGg4U=GQwTUcZhNv-mJPZ8JxO4JSLw_1UwQSorYfCv38u1uuUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marian Corcodel <corcodel.marian@gmail.com> :
> This is specified on data sheet  only when LS  is set must evaluate
> RES   bit very important patch.Whi say no here not undestand .Please
> read Data sheet for more info.

Your patch ignores the following fact: the driver works with maximally
sized receive buffers to avoid fragmented packets - see git log for an
enlightning journey through the history of the r8169 driver.

Beyond blind datasheet compliance, have you been able to experience
FirstFrag = 0 or LastFrag = 0 receive descriptors with the current
in-kernel driver ?

-- 
Ueimor
