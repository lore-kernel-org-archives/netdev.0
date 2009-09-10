From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Thu, 10 Sep 2009 17:42:11 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909101741520.9964@V090114053VZO-1>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1> <4AA7E082.90807@gmail.com>
 <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1> <4AA963A4.5080509@gmail.com> <4AA97183.3030008@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:59100 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752376AbZIJVn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 17:43:27 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 001F682C44F
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 17:44:34 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7hR3ZB5Fi5ui for <netdev@vger.kernel.org>;
	Thu, 10 Sep 2009 17:44:29 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 57A8782C47B
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 17:44:29 -0400 (EDT)
In-Reply-To: <4AA97183.3030008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Sep 2009, Eric Dumazet wrote:

> and idle=mwait  (or hpet and C2/C3 states are used on this machine and
> wakeups are slow)

We disabled C states here.
