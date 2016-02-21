From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH next v4 1/3] ipvlan: scrub skb before routing in L3 mode.
Date: Sat, 20 Feb 2016 20:35:42 -0800
Message-ID: <CAM_iQpWsSQSUVb0tAALmGBnua11ORY5NkWhv8xrXzjwd20eoqQ@mail.gmail.com>
References: <1456025492-30274-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:34830 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbcBUR5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:57:03 -0500
Received: by mail-yw0-f169.google.com with SMTP id g127so103391255ywf.2
        for <netdev@vger.kernel.org>; Sun, 21 Feb 2016 09:57:03 -0800 (PST)
In-Reply-To: <1456025492-30274-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 20, 2016 at 7:31 PM, Mahesh Bandewar <mahesh@bandewar.net> wrote:
> From: Mahesh Bandewar <maheshb@google.com>
>
> Scrub skb before hitting the iptable hooks to ensure packets hit
> these hooks. Set the xnet param only when the packet is crossing the
> ns boundry so if the IPvlan slave and master belong to the same ns,
> the param will be set to false.
>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> CC: Cong Wang <xiyou.wangcong@gmail.com>

Looks good to me now,

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks for updating it!
