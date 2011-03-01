From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch net-next-2.6] bonding: remove skb_share_check in handle_frame
Date: Tue, 1 Mar 2011 23:12:33 +0800
Message-ID: <AANLkTimk_jyTYO8=8LRgY3C1un38qb1q9C-DbKWHirPS@mail.gmail.com>
References: <20110301062250.GB2855@psychotron.redhat.com> <20110301092907.GG2855@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58608 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755100Ab1CAPM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 10:12:57 -0500
Received: by fxm17 with SMTP id 17so4894070fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 07:12:56 -0800 (PST)
In-Reply-To: <20110301092907.GG2855@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2011 at 5:29 PM, Jiri Pirko <jpirko@redhat.com> wrote:
> Unapplicable, sorry (wrong branch :(). Here's corrected patch:
>
> Subject: [PATCH net-next-2.6 v2] bonding: remove skb_share_check in handle_frame
>
> No need to do share check here.
>

I don't think so. Although you avoid netif_rx(), you can't avoid
ptype_all handlers. In fact, all the RX handlers should has this
check(), if they may modify the skb.


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
