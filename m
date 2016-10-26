From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] tc: m_mirred: Add support for ingress
 redirect/mirror
Date: Wed, 26 Oct 2016 11:21:35 -0700
Message-ID: <20161026112135.395f9983@xeon-e3>
References: <20161019141409.23172-1-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33754 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751129AbcJZSVU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 14:21:20 -0400
Received: by mail-pf0-f172.google.com with SMTP id 197so1167746pfu.0
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 11:21:20 -0700 (PDT)
In-Reply-To: <20161019141409.23172-1-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Oct 2016 17:14:09 +0300
Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:

> So far, only the 'egress' direction was implemented.
> 
> Allow specifying 'ingress' as the direction packet appears on the target
> interface.
> 
> For example, this takes incoming 802.1q frames on veth0 and redirects
> them for input on dummy0:
> 
>  # tc filter add dev veth0 parent ffff: pref 1 protocol 802.1q basic \
>      action mirred ingress redirect dev dummy0
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied to net-next branch
