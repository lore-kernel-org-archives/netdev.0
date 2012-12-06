From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net : enable tx time stamping in the vde driver.
Date: Thu, 6 Dec 2012 19:57:43 +0100
Message-ID: <20121206185742.GA2175@netboy.at.omicron.at>
References: <1354807505-21222-1-git-send-email-paul.chavent@onera.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jdike@addtoit.com, richard@nod.at,
	user-mode-linux-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Paul Chavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:64104 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946494Ab2LFS5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 13:57:53 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so3814974eek.19
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 10:57:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1354807505-21222-1-git-send-email-paul.chavent@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 06, 2012 at 04:25:05PM +0100, Paul Chavent wrote:
> This new version moves the skb_tx_timestamp in the main uml
> driver. This should avoid the need to call this function in each
> transport (vde, slirp, tuntap, ...). It also add support for ethtool
> get_ts_info.
> 
> Signed-off-by: Paul Chavent <paul.chavent@onera.fr>

Acked-by: Richard Cochran <richardcochran@gmail.com>
