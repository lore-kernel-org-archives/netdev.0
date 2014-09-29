From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next] r8169: add support for Byte Queue Limits
Date: Mon, 29 Sep 2014 14:03:10 -0700
Message-ID: <1412024590.30721.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412024209-25468-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:41131 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaI2VDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 17:03:11 -0400
Received: by mail-pa0-f44.google.com with SMTP id et14so3364184pad.17
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 14:03:11 -0700 (PDT)
In-Reply-To: <1412024209-25468-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-29 at 22:56 +0200, Florian Westphal wrote:
> tested on RTL8168d/8111d.

One small nit :

> @@ -6691,6 +6695,7 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
>  static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
>  {
>  	unsigned int dirty_tx, tx_left;
> +	unsigned bytes_compl = 0, pkts_compl = 0;

unsigned int bytes_compl = 0, pkts_compl = 0;
