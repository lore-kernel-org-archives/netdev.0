From: David Miller <davem@davemloft.net>
Subject: Re: Kernel Oops in __inet_twsk_kill()
Date: Wed, 05 Nov 2014 14:39:29 -0500 (EST)
Message-ID: <20141105.143929.861274469992898400.davem@davemloft.net>
References: <545A49B4.7090107@iogearbox.net>
	<CAHA+R7PAdVS=TBd8ZDAW3wdadjNEVjiyemrs54wNp8fdtCMvZQ@mail.gmail.com>
	<FB8A4655DFD2B34DB16AE06DDDD6C0E231A71CE3@SJEXCHMB12.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, borkmann@iogearbox.net,
	netdev@vger.kernel.org
To: charley.chu@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaKETje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 14:39:34 -0500
In-Reply-To: <FB8A4655DFD2B34DB16AE06DDDD6C0E231A71CE3@SJEXCHMB12.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Charley (Hao Chuan) Chu" <charley.chu@broadcom.com>
Date: Wed, 5 Nov 2014 19:16:09 +0000

> The problem has been fixed. It is introduced by a third party patch,
> which decreases the refcnt of timewait socket.

This is something that really drives me nuts, seriously?

Never report problems to us when you have such patches applied.

It is an even larger crime to not mention this at all from the
beginning, because we might start to investigate and waste our
precious time doing so.
