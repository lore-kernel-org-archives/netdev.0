From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5] net: Loopback ifindex is constant now
Date: Mon, 06 Aug 2012 13:54:31 +0200
Message-ID: <1344254071.26674.15.camel@edumazet-glaptop>
References: <501F9CAF.3030605@parallels.com>
	 <501F9D2B.8000504@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55057 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756006Ab2HFLyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 07:54:36 -0400
Received: by bkwj10 with SMTP id j10so990218bkw.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 04:54:34 -0700 (PDT)
In-Reply-To: <501F9D2B.8000504@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 14:32 +0400, Pavel Emelyanov wrote:
> As pointed out, there are places, that access net->loopback_dev->ifindex
> and after ifindex generation is made per-net this value becomes constant
> equals 1. So go ahead and introduce the LOOPBACK_IFINDEX constant and use
> it where appropriate.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

What guarantee do we have that loopback is the first device per net ?

You should add this to the changelog because its not that obvious.
