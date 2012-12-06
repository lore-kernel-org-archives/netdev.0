From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net: fixup tx time stamping for uml vde driver.
Date: Thu, 6 Dec 2012 07:55:59 +0100
Message-ID: <20121206065558.GA2700@netboy.at.omicron.at>
References: <1354717253-8737-1-git-send-email-paul.chavent@onera.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jdike@addtoit.com, richard@nod.at,
	user-mode-linux-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Paul Chavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:64555 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932331Ab2LFG4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 01:56:08 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so2353778eaa.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 22:56:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1354717253-8737-1-git-send-email-paul.chavent@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2012 at 03:20:53PM +0100, Paul Chavent wrote:
> Call skb_tx_timestamp after write completion.
> 
> Signed-off-by: Paul Chavent <paul.chavent@onera.fr>

The subject line would better describe the changes if it would read,
"enable tx time stamping in the uml vde driver."

Can you please also add support for ethtool get_ts_info?

Thanks,
Richard
