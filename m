From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] ping: ICMP error replies while errno < 0 is a hard error
Date: Wed, 8 Jun 2016 10:53:43 +0900
Message-ID: <57577AA7.10005@miraclelinux.com>
References: <20160607120522.9474-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, netdev@vger.kernel.org,
	hideaki@yoshifuji.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34594 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754590AbcFHBxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 21:53:47 -0400
Received: by mail-pa0-f48.google.com with SMTP id bz2so51302415pad.1
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 18:53:47 -0700 (PDT)
In-Reply-To: <20160607120522.9474-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Jason A. Donenfeld wrote:
> There are some odd conditions in which a device will return an error for
> sendto, while at the same time an ICMP error response is generated. In
> this case, with the current code, the packet is retransmitted in a
> flood, which is not what anybody wants. In fact, when these two
> conditions occur, we want to treat the packet as a "hard local error"
> and do the ordinary pause as before. The reasoning is that if we did
> receive an ICMP error message, then the packet was transmitted, and so
> it should be accounted for. But, since we also received an errno, this
> should be reported to the user, as something is wonky with their network
> interface.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Applied. Thank you.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
