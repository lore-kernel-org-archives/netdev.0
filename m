From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/5] udp: Generalize skb_udp_segment
Date: Fri, 26 Sep 2014 12:39:50 -0700
Message-ID: <CAADnVQJgoW1SbkK6hoJcRtTwyKxgNBtFYqBF-5aW9D4=Zi5ofg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:45259 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754243AbaIZTjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 15:39:52 -0400
Received: by mail-la0-f43.google.com with SMTP id gb8so5507935lab.2
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 12:39:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 9:22 AM, Tom Herbert <therbert@google.com> wrote:
> skb_udp_segment is the function called from udp4_ufo_fragment to
> segment a UDP tunnel packet. This function currently assumes
> segmentation is transparent Ethernet bridging (i.e. VXLAN
> encapsulation). This patch generalizes the function to
> operate on either Ethertype or IP protocol.

this is great generalization.
Do you envision that type_ether will cover vlan and mpls, right?
What if somebody crazy adds a new thing after udp encap
that is neither ethernet nor ip header?
Like encryption header?
I think it would fit this model well...
