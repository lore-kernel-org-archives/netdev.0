From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 2/3] ipv6, route: remove BACKTRACK() macro
Date: Tue, 11 Sep 2012 09:22:53 +0800
Message-ID: <1347326573.30731.12.camel@cr0>
References: <1347281326-26890-1-git-send-email-amwang@redhat.com>
	 <1347281326-26890-2-git-send-email-amwang@redhat.com>
	 <504DEE89.8030606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50306 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753121Ab2IKBXA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 21:23:00 -0400
In-Reply-To: <504DEE89.8030606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-10 at 21:43 +0800, Shan Wei wrote:
> Cong Wang said, at 2012/9/10 20:48:
> > It doesn't save any code, nor it helps readability.
> > 
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> this macro, don't reduce showing lines?
> with it, more readability on terminal, right?

I can't agree, try to read the goto inside, you have to scroll your
screen down when you read the second BACTRACK().

> 
> P.S. when doing backport work, some bored patches influence me.
> this patch and [PATCH 3/3] are typical. :-)
> 

Why not just cherry-pick it too? `git cherry-pick` is handy. ;)
