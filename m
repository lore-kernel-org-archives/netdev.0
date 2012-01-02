From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] fix for nfacct infrastructure in net-next
Date: Mon, 2 Jan 2012 02:04:15 +0100
Message-ID: <20120102010415.GA23310@1984>
References: <1325434945-21900-1-git-send-email-pablo@netfilter.org>
 <20120101162358.GA21795@1984>
 <20120101.180229.1338519415596129407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40953 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328Ab2ABBEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jan 2012 20:04:21 -0500
Content-Disposition: inline
In-Reply-To: <20120101.180229.1338519415596129407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Sun, Jan 01, 2012 at 06:02:29PM -0500, David Miller wrote:
> I'm not pulling this.
> 
> If I pull from your "corrected" URL, "git://1984.lsi.us.es/net-next nf-next"
> it starts to download 17937 objects.  Which means it's going to bring in all
> of your -next work as well as my net-next tree upon which it is based, not
> just this one bug fix.
>
> These mistakes should never happen in the first place.
> 
> If you actually use "git request-pull" to generate the pull request
> email body, you can NEVER get the URL wrong, GIT enforces it to be
> correct and it enforces that the changes in your local tree are
> present at the remote URL as well.

You caught me here, I wasn't using git request-pull. I'll do next time,
sorry.

> You can't make these kinds of errors and oversights when you want to
> ask me to pull in bug fixes at the very last minute when Linus is
> about to make a final release.

I think there's a misunderstanding.

This is not intended for current 3.2-rc7. This is a fix for something
that is in your net-next tree (upcoming 3.3).

I can wait and resubmit this later, we have the entire 3.3-rc cycle to
get it fixed. Sorry for rushing you.

> Just toss these fixes, if they are so important submit them to Greg KH
> and the -stable branch after 3.2.0-final goes out.
