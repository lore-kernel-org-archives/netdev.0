From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH] net: skbuff: Fix length validation in skb_vlan_pop()
Date: Mon, 19 Sep 2016 18:20:14 +0300
Message-ID: <20160919182014.46d5da77@halley>
References: <1474193358-20133-1-git-send-email-shmulik.ladkani@gmail.com>
        <CAOrHB_D2ytTK9WjfCPL87E1QomeXg+2GfAvo8N8xCcJULhAC=w@mail.gmail.com>
        <20160919091538.56defd2b@pixies>
        <57DFD8A1.1090103@iogearbox.net>
        <20160919160517.6ee28bde@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>, Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36841 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750801AbcISPU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 11:20:27 -0400
Received: by mail-wm0-f49.google.com with SMTP id w84so81981744wmg.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 08:20:27 -0700 (PDT)
In-Reply-To: <20160919160517.6ee28bde@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Sep 2016 16:05:17 +0300 Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:
> Also, I'm okay with removing the excess 'skb->mac_len < VLAN_ETH_HLEN'
> condition if it is agreed that the "tag exists but insufficient to pop"
> semantic is no longer wanted.

Thinking this over, the condition is indeed superflous, will send a v2.
