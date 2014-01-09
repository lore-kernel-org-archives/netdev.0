From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: xfrm6: silence sparse warning
Date: Thu, 9 Jan 2014 15:04:51 -0800
Message-ID: <20140109150451.30b57b2b@nehalam.linuxnetplumber.net>
References: <1389149801-29011-1-git-send-email-ying.xue@windriver.com>
	<20140107.224357.1577838150943921013.davem@davemloft.net>
	<52CCE83D.5080909@windriver.com>
	<20140108.005656.1582987448512057112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, steffen.klassert@secunet.com,
	dborkman@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:41457 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbaAIXEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 18:04:54 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so3943608pab.33
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 15:04:54 -0800 (PST)
In-Reply-To: <20140108.005656.1582987448512057112.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 08 Jan 2014 00:56:56 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Ying Xue <ying.xue@windriver.com>
> Date: Wed, 8 Jan 2014 13:55:09 +0800
> 
> > 3. Just drop the patch
> 
> This is the only suitable thing to do.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

There was some patches floating around to eliminate uses of variable
length array in the kernel since they aren't supported by CLANG.
