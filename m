From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net] net: skbuff: Fix incorrect skb->mac_len adjustment
 in skb_vlan_push()
Date: Wed, 28 Sep 2016 11:13:10 +0300
Message-ID: <20160928111310.12ce6961@pixies>
References: <1474997505-5059-1-git-send-email-shmulik.ladkani@gmail.com>
        <CAOrHB_C6H8AqqfLDvj296LnnLC7dLX5724cxGXujLTbgSBf50A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: pravin shelar <pshelar@ovn.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33568 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751234AbcI1INR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 04:13:17 -0400
Received: by mail-wm0-f54.google.com with SMTP id d66so35124982wmf.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 01:13:16 -0700 (PDT)
In-Reply-To: <CAOrHB_C6H8AqqfLDvj296LnnLC7dLX5724cxGXujLTbgSBf50A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, 27 Sep 2016 13:04:35 -0700, pshelar@ovn.org wrote:
> 
> OVS MPLS does depends on mac-len to track MPLS header (ref
> skb_mpls_header()). Therefore vlan header changes needs to update
> mac-len.

Thanks for the explanation.
I'm working on a better fix.

Regards,
Shmulik
