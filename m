From: David Miller <davem@davemloft.net>
Subject: Re: commit d0af71a3573 for 3.19.y stable
Date: Tue, 21 Apr 2015 13:50:25 -0400 (EDT)
Message-ID: <20150421.135025.835784914901732036.davem@davemloft.net>
References: <CA+5PVA5oNEWJbU+VdG1rP+tbT1q55W2MSe3afOHP3bcP2h660A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: jwboyer@fedoraproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54467 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755389AbbDURu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 13:50:29 -0400
In-Reply-To: <CA+5PVA5oNEWJbU+VdG1rP+tbT1q55W2MSe3afOHP3bcP2h660A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Boyer <jwboyer@fedoraproject.org>
Date: Wed, 1 Apr 2015 20:34:22 -0400

> Another possible stable candidate.  We had a report[1] of deadlocks
> with tigon devices on 3.19.y and the commit below fixes it.  It
> cherry-picks cleanly on top of 3.19.3.  I don't see it queued up so I
> thought I would point it out.
> 
> commit d0af71a3573f1217b140c60b66f1a9b335fb058b
> Author: Jun'ichi Nomura \(NEC\) <j-nomura@ce.jp.nec.com>
> Date:   Thu Feb 12 01:26:24 2015 +0000
> 
>     tg3: Hold tp->lock before calling tg3_halt() from tg3_init_one()

Queued up, thanks Josh.
