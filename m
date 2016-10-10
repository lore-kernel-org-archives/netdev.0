From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2 net-next] tc: m_vlan: Add vlan modify action
Date: Sun, 9 Oct 2016 19:12:06 -0700
Message-ID: <20161009191206.401b10ad@xeon-e3>
References: <1474567265-3397-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35760 "EHLO
        mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbcJJCTb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 22:19:31 -0400
Received: by mail-pa0-f53.google.com with SMTP id qn10so41947330pac.2
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 19:19:31 -0700 (PDT)
In-Reply-To: <1474567265-3397-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Sep 2016 21:01:05 +0300
Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:

> The 'vlan modify' action allows to replace an existing 802.1q tag
> according to user provided settings.
> It accepts same arguments as the 'vlan push' action.
> 
> For example, this replaces vid 6 with vid 5:
> 
>  # tc filter add dev veth0 parent ffff: pref 1 protocol 802.1q \
>       basic match 'meta(vlan mask 0xfff eq 6)' \
>       action vlan modify id 5 continue
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied to net-next (for 4.9)
