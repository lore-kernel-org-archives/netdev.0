From: Joe Perches <joe@perches.com>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO
 packets'
Date: Thu, 17 May 2012 15:27:40 -0700
Message-ID: <1337293660.8872.24.camel@joe2Laptop>
References: <20120517121800.GA18052@1wt.eu>
	 <1337287279.3403.44.camel@edumazet-glaptop> <20120517211414.GP14498@1wt.eu>
	 <1337290822.3403.47.camel@edumazet-glaptop>
	 <1337291410.3403.52.camel@edumazet-glaptop>
	 <1337292119.3403.60.camel@edumazet-glaptop> <20120517221641.GS14498@1wt.eu>
	 <1337293351.3403.67.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44381 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030409Ab2EQW1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 18:27:41 -0400
In-Reply-To: <1337293351.3403.67.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-18 at 00:22 +0200, Eric Dumazet wrote:
> On Fri, 2012-05-18 at 00:16 +0200, Willy Tarreau wrote:
> > I have simplified the expression,
> > since ((A && !B) || !A) == !(A & B).

Perhaps it's clearer for a reader the first way and
any decent compiler (even gcc) could probably do that
optimization.
