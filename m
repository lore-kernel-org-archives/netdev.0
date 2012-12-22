From: Borislav Petkov <bp@alien8.de>
Subject: Re: Regression in 3.8-rc1:  "BUG: sleeping function called from
 invalid context"
Date: Sat, 22 Dec 2012 19:30:44 +0100
Message-ID: <20121222183044.GA10263@liondog.tnic>
References: <50D5E9D9.3070904@lwfinger.net>
 <20121222180247.GA10250@liondog.tnic>
 <1356199828.21834.8500.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skyhub.de ([78.46.96.112]:50201 "EHLO mail.skyhub.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751731Ab2LVSar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Dec 2012 13:30:47 -0500
Content-Disposition: inline
In-Reply-To: <1356199828.21834.8500.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 22, 2012 at 10:10:28AM -0800, Eric Dumazet wrote:
> RTNL is a mutex, its perfectly valid to use GFP_KERNEL while holding a
> mutex.

Right, sorry. The check fires because we have preemption disabled.

> As replied before your mail, fix for the problem is already in David
> tree.

Yep, saw that after hitting send.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
