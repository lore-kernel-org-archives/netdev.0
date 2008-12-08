From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/3] hso modem signals patch fix
Date: Mon, 8 Dec 2008 11:34:38 +0000
Message-ID: <20081208113438.02cc9173@lxorguk.ukuu.org.uk>
References: <493CF8F5.30007@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux netdev Mailing list <netdev@vger.kernel.org>,
	Linux USB kernel mailing list <linux-usb@vger.kernel.org>
To: Denis Joseph Barrow <D.Barow@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:50312 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751640AbYLHLe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 06:34:27 -0500
In-Reply-To: <493CF8F5.30007@option.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Makes TIOCM ioctls for Data Carrier Detect & related functions
> work like /drivers/serial/serial-core.c potentially needed 
> for pppd & similar user programs.   
> Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>

Doesn't apply versus the current ttydev tree stack which has other hso
related patches in it including a previous modem patch you sent. Please
send updates versus the current ttydev tree and your previous patch.

http://zeniv.linux.org.uk/~alan has the ttydev patch stack. If the most
sensible thing to do is to drop your old patch and swap in a version of
this one then that is fine but let me know what should happen to it.

Also please send/cc tty related patches to me. I appreciate this is also
a network driver but the tty side stuff really does need to go via ttydev
as there are a lot of tty changes currently going on.

NAK this therefore

Alan
