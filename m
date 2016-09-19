From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH v2 1/2] net: skbuff: Remove errornous length validation
 in skb_vlan_pop()
Date: Mon, 19 Sep 2016 19:28:56 +0300
Message-ID: <20160919192856.31bacaba@halley>
References: <1474300400-32362-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Pravin Shelar <pshelar@ovn.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37221 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750898AbcISQ3E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 12:29:04 -0400
Received: by mail-wm0-f41.google.com with SMTP id b130so71607721wmc.0
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 09:29:03 -0700 (PDT)
In-Reply-To: <1474300400-32362-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Sep 2016 18:53:19 +0300 Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:
> Remove the 'skb->len < VLAN_ETH_HLEN' condition entirely:
> It is superfluous since inner '__skb_vlan_pop' already verifies there
> are VLAN_ETH_HLEN writable bytes at the mac_header.

Please disregard, will send a v3.
