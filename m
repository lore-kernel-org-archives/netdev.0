From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm_user: return error pointer instead of NULL #2
Date: Mon, 17 Sep 2012 09:18:53 +0200
Message-ID: <20120917071853.GD13023@secunet.com>
References: <1347652712-14584-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35744 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751462Ab2IQHSz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 03:18:55 -0400
Content-Disposition: inline
In-Reply-To: <1347652712-14584-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 14, 2012 at 09:58:32PM +0200, Mathias Krause wrote:
> When dump_one_policy() returns an error, e.g. because of a too small
> buffer to dump the whole xfrm policy, xfrm_policy_netlink() returns
> NULL instead of an error pointer. But its caller expects an error
> pointer and therefore continues to operate on a NULL skbuff.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
