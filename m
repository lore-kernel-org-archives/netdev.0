From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] NetLabel: Verify sensitivity level has a valid CIPSO mapping
Date: Fri, 2 Mar 2007 11:12:12 -0500
Message-ID: <200703021112.13063.paul.moore@hp.com>
References: <20070228200140.491071752@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:38728 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992574AbXCBQM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 11:12:28 -0500
In-Reply-To: <20070228200140.491071752@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, February 28 2007 3:01:31 pm Paul Moore wrote:
> The current CIPSO engine has a problem where it does not verify that the
> given sensitivity level has a valid CIPSO mapping when the "std" CIPSO DOI
> type is used.  The end result is that bad packets are sent on the wire
> which should have never been sent in the first place.  This patch corrects
> this problem by verifying the sensitivity level mapping similar to what is
> done with the category mapping.  This patch also changes the returned error
> code in this case to -EPERM to better match what the category mapping
> verification code returns.
>
> Signed-off-by: Paul Moore <paul.moore@hp.com>
> ---
>  net/ipv4/cipso_ipv4.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)

I probably should have been more clear in the original patch posting ... this 
is a bugfix patch which I believe should go into 2.6.21 (as well as 
the -stable tree, but I know they like to see it hit Linus' tree first).

-- 
paul moore
linux security @ hp
