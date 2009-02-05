From: David Miller <davem@davemloft.net>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Thu, 05 Feb 2009 15:29:06 -0800 (PST)
Message-ID: <20090205.152906.221253085.davem@davemloft.net>
References: <b6a2187b0902050641h7943816ds26275a320e724440@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, rjw@sisk.pl,
	torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jeff.chua.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753131AbZBEX3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 18:29:10 -0500
In-Reply-To: <b6a2187b0902050641h7943816ds26275a320e724440@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Chua <jeff.chua.linux@gmail.com>
Date: Thu, 5 Feb 2009 22:41:52 +0800

[ netdev CC:'d, please always do this for networking stuff ]

> The following commit breaks "rlogin". Symptom is the terminal just
> hangs before login to the remote machine. No error, just the cursor
> never come back. "~." or type "exit" will exit from remote session.
> Only happens "sometimes". Happens more often if you try many times.
> 
> I've reverted the commit, and rlogin works now.
 ...
> commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Thu Dec 25 17:12:58 2008 -0800
> 
>     tcp: Always set urgent pointer if it's beyond snd_nxt

Oh well, what is running on each side of the rlogin attempt?

Herbert, please help Jeff try to track down the cause of this.
If we can't figure it out soon I'll have to revert.
