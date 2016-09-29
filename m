From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 1/2] openvswitch: mpls: set network header
 correctly on key extract
Date: Thu, 29 Sep 2016 16:02:39 -0700
Message-ID: <CAOrHB_D_66_agnsSYE_tKvrEH_25cSGm9J+97Vu1ht-zooqMVA@mail.gmail.com>
References: <cover.1475176437.git.jbenc@redhat.com> <170be69b8496bf37e90915e2f05af0464d5f09c6.1475176437.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:46826 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752328AbcI2XCp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 19:02:45 -0400
Received: from mfilter22-d.gandi.net (mfilter22-d.gandi.net [217.70.178.150])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 16588C5A46
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 01:02:43 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter22-d.gandi.net (mfilter22-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id yFylwy9jTu3s for <netdev@vger.kernel.org>;
        Fri, 30 Sep 2016 01:02:41 +0200 (CEST)
Received: from mail-it0-f51.google.com (mail-it0-f51.google.com [209.85.214.51])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 84AFFC5A4E
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 01:02:41 +0200 (CEST)
Received: by mail-it0-f51.google.com with SMTP id r192so13775564ita.0
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 16:02:41 -0700 (PDT)
In-Reply-To: <170be69b8496bf37e90915e2f05af0464d5f09c6.1475176437.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 29, 2016 at 12:19 PM, Jiri Benc <jbenc@redhat.com> wrote:
> After the 48d2ab609b6b ("net: mpls: Fixups for GSO"), MPLS handling in
> openvswitch was changed to have network header pointing to the start of the
> MPLS headers and inner_network_header pointing after the MPLS headers.
>
> However, key_extract was missed by the mentioned commit, causing incorrect
> headers to be set when a MPLS packet just enters the bridge or after it is
> recirculated.
>
> Fixes: 48d2ab609b6b ("net: mpls: Fixups for GSO")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
