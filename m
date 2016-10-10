From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net 1/3] openvswitch: vlan: remove wrong likely statement
Date: Mon, 10 Oct 2016 13:05:36 -0700
Message-ID: <CAOrHB_BXEWJQ04R+N=E0F-+3tZPgyCcqZqsdOZ=T_TB+prH4NQ@mail.gmail.com>
References: <cover.1476111550.git.jbenc@redhat.com> <a4b63fa787569359d227beecbdbf9b023081cffc.1476111550.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:35108 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751969AbcJJUFn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 16:05:43 -0400
Received: from mfilter43-d.gandi.net (mfilter43-d.gandi.net [217.70.178.174])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 058EB41C07E
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 22:05:40 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter43-d.gandi.net (mfilter43-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id ybKg9pD6tv64 for <netdev@vger.kernel.org>;
        Mon, 10 Oct 2016 22:05:38 +0200 (CEST)
Received: from mail-it0-f44.google.com (mail-it0-f44.google.com [209.85.214.44])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 994BF41C087
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 22:05:38 +0200 (CEST)
Received: by mail-it0-f44.google.com with SMTP id l13so82297935itl.1
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 13:05:38 -0700 (PDT)
In-Reply-To: <a4b63fa787569359d227beecbdbf9b023081cffc.1476111550.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2016 at 8:02 AM, Jiri Benc <jbenc@redhat.com> wrote:
> This code is called whenever flow key is being extracted from the packet.
> The packet may be as likely vlan tagged as not.
>
> Fixes: 018c1dda5ff1 ("openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink attributes")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
