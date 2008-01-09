From: Brent Casavant <bcasavan@sgi.com>
Subject: Re: AF_UNIX MSG_PEEK bug?
Date: Wed, 9 Jan 2008 12:01:42 -0600 (CST)
Message-ID: <alpine.BSF.1.00.0801091201180.35527@pkunk.americas.sgi.com>
References: <alpine.BSF.1.00.0801081556580.24286@pkunk.americas.sgi.com> <200801092004.IJJ48416.FVQOtOLFSOJHMF@I-love.SAKURA.ne.jp>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:50626 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751844AbYAISBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 13:01:44 -0500
In-Reply-To: <200801092004.IJJ48416.FVQOtOLFSOJHMF@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Jan 2008, Tetsuo Handa wrote:

> Did you try MSG_WAITALL flag? See "man 2 recv".
> A TCP socket handles data in bytes.
> You cannot complain if the amount received by recv() is smaller than expected
> unless you use MSG_WAITALL flag.

Yes. It made no difference, as noted in the comments in the
provided test program.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
