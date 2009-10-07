From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ppp: fix comments - ppp_{sync,asynctty}_receive()
 may sleep
Date: Wed, 07 Oct 2009 01:28:21 -0700 (PDT)
Message-ID: <20091007.012821.184426837.davem@davemloft.net>
References: <20091001142844.C50E511186D@xenon.ts.pxnet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, alan@linux.intel.com, paulus@samba.org,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	jarkao2@gmail.com, linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36057
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932321AbZJGI20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 04:28:26 -0400
In-Reply-To: <20091001142844.C50E511186D@xenon.ts.pxnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Thu,  1 Oct 2009 16:28:44 +0200 (CEST)

> The receive_buf methods of the N_PPP and N_SYNC_PPP line disciplines,
> ppp_asynctty_receive() and ppp_sync_receive(), call tty_unthrottle()
> which may sleep. Fix the comments claiming otherwise.
> 
> Impact: documentation
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied, thanks.
