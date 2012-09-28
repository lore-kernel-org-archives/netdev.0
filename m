From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] net: fix neigh_resolve_output can cause skb_under_panic
Date: Fri, 28 Sep 2012 16:52:09 -0700
Message-ID: <20120928235209.GA11474@kroah.com>
References: <CA3E5132752D1F49871ED0FC40D56BBA43ECE2E72D@EUSAACMS0701.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"michel@digirati.com.br" <michel@digirati.com.br>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ramesh Nagappa <ramesh.nagappa@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:32885 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964876Ab2I1XwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 19:52:11 -0400
Content-Disposition: inline
In-Reply-To: <CA3E5132752D1F49871ED0FC40D56BBA43ECE2E72D@EUSAACMS0701.eamcs.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 28, 2012 at 07:40:39PM -0400, Ramesh Nagappa wrote:
> >From fd023edd911ef12aca38a72b40241661c202684f Mon Sep 17 00:00:00 2001
> From: Ramesh Nagappa <ramesh.nagappa@ericsson.com>
> Date: Thu, 27 Sep 2012 10:20:58 -0700
> Subject: [PATCH] net: fix neigh_resolve_output can cause skb_under_panic

Why is all of this in the middle of the changelog section?

I'm guessing you didn't use 'git send-email' for this?

And why are you copying me on the patch?

> The retry loop in the neigh_resolve_output() and neigh_connected_output() can add
> a hard_header without resetting the skb to network header. This causes the
> skb_push() in dev_hard_header() to fail.
> Signed-off-by: Ramesh Nagappa <ramesh.nagappa@ericsson.com>
> Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
> Reviewed-by: Billie Alsup <billie.alsup@ericsson.com>
> Reviewed-by: Robert Coulson <robert.coulson@ericsson.com>

You need a blank line before the first Signed-off-by: line.  Surely one
of the reviewers should have caught this basic thing?

greg k-h
