From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] AF_UNIX: Fix deadlock on connecting to shutdown socket
Date: Mon, 19 Oct 2009 20:07:12 +0200
Message-ID: <20091019180712.GA2959@ami.dom.local>
References: <4ADC010C.5070809@hitachi.com>
 <20091019115713.GB6869@ff.dom.local>
 <20091019.061459.193694892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tomoki.sekiyama.qu@hitachi.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk,
	satoshi.oshima.fk@hitachi.com, hidehiro.kawai.ez@hitachi.com,
	hideo.aoki.tk@hitachi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:51226 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754781AbZJSSH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 14:07:26 -0400
Content-Disposition: inline
In-Reply-To: <20091019.061459.193694892.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2009 at 06:14:59AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 19 Oct 2009 11:57:13 +0000
> 
> > Isn't the shutdown call expected to change sk_state to TCP_CLOSE?
> 
> No, because the send side is still up and operational, it's
> only a half duplex close.

OK, thanks for the explanation,
Jarek P.
