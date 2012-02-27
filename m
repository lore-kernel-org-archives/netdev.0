From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: fix tcp_shifted_skb() adjustment of lost_cnt_hint
 for FACK
Date: Tue, 28 Feb 2012 01:39:50 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1202280127490.17924@melkinpaasi.cs.helsinki.fi>
References: <1329200528-19718-1-git-send-email-ncardwell@google.com> <20120214.144033.848861752845052421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, nanditad@google.com,
	ycheng@google.com, therbert@google.com, subramanian.vijay@gmail.com
To: David Miller <davem@davemloft.net>, ncardwell@google.com,
	Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49380 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755305Ab2B0Xjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 18:39:52 -0500
In-Reply-To: <20120214.144033.848861752845052421.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Feb 2012, David Miller wrote:

> From: Neal Cardwell <ncardwell@google.com>
> Date: Tue, 14 Feb 2012 01:22:08 -0500
> 
> > This commit ensures that lost_cnt_hint is correctly updated in
> > tcp_shifted_skb() for FACK TCP senders. The lost_cnt_hint adjustment
> > in tcp_sacktag_one() only applies to non-FACK senders, so FACK senders
> > need their own adjustment.
> > 
> > This applies the spirit of 1e5289e121372a3494402b1b131b41bfe1cf9b7f -
> > except now that the sequence range passed into tcp_sacktag_one() is
> > correct we need only have a special case adjustment for FACK.
> > 
> > Signed-off-by: Neal Cardwell <ncardwell@google.com>
> 
> Applied, and queued up for -stable, thanks Neil.

There has been lots of TCP related warnings posted recently to netdev.
Finding out which of these three recent changes caused which warning and 
if they're all cured by the full series is bit challenging. ...IMHO we 
should wait a bit more until these recent fixes are put to stable in order 
to verify that the dust has really settled.


-- 
 i.
