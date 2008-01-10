From: Brent Casavant <bcasavan@sgi.com>
Subject: Re: AF_UNIX MSG_PEEK bug?
Date: Wed, 9 Jan 2008 19:19:04 -0600 (CST)
Message-ID: <alpine.BSF.1.00.0801091914220.35527@pkunk.americas.sgi.com>
References: <E1JCkrp-0000vX-00@gondolin.me.apana.org.au>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: penguin-kernel@i-love.sakura.ne.jp, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:37768 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755695AbYAJBTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 20:19:07 -0500
In-Reply-To: <E1JCkrp-0000vX-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Jan 2008, Herbert Xu wrote:

> The POSIX text for MSG_WAITALL actually says that when used in
> conjunction with MSG_PEEK it may not return the full data.

That's fine.  The problem is that the peek operation returns less
data than requested even when sufficient data is available on the
receive queue.

> However, if you really want this to
> happen it would help if you had attached a patch :)

A patch is definitely in progress.  I'm a little confused as
to the difference between unix_detach_fds() and scm_fp_dup()
in the MSG_PEEK versus !MSG_PEEK paths in unix_stream_recvmsg(),
however once I figure that out a patch should be forthcoming.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
