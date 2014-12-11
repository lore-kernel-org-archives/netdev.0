From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2] ip: Simplify executing ip cmd within namespace
Date: Thu, 11 Dec 2014 19:08:46 +0100
Message-ID: <20141211190846.1e25e7fa@griffin>
References: <1418252195-2612-1-git-send-email-vadim4j@gmail.com>
	<20141211170928.62c8e637@griffin>
	<20141211163335.GA27913@angus-think.wlc.globallogic.com>
	<5489D56E.4010505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vadim4j@gmail.com, netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35107 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932486AbaLKSIv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 13:08:51 -0500
In-Reply-To: <5489D56E.4010505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Dec 2014 15:33:34 -0200, Marcelo Ricardo Leitner wrote:
> In that case, it would be interesting to also accelerate the original use 
> case, no? So all usages we currently have will benefit from this speed up 
> without a change.
> 
> if (command to be executed == myself)
>    switch namespace, continue without fork/exec..

It's never good idea to do such tricks behind the user's back. This
particular case could easily break for users wanting to execute a
different ip binary (for whatever reason).

All programs should do what they are told to do, not try to outsmart
the user.

 Jiri

-- 
Jiri Benc
