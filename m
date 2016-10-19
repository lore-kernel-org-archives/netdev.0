From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v12 3/9] openvswitch: pass mac_proto to ovs_vport_send
Date: Tue, 18 Oct 2016 22:11:38 -0700
Message-ID: <CAOrHB_BWpzHjiFGikUCyjW5WnNYjqXT+SxbVdBFRUcHPH+Yfgg@mail.gmail.com>
References: <cover.1476708212.git.jbenc@redhat.com> <c954507a960add0ae9410c19fd40eebc1fda0f95.1476708212.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:33134 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756785AbcJSFLn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 01:11:43 -0400
Received: from mfilter1-d.gandi.net (mfilter1-d.gandi.net [217.70.178.130])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id A9EA341C091
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 07:11:41 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter1-d.gandi.net (mfilter1-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 9_Y84XhLnyp2 for <netdev@vger.kernel.org>;
        Wed, 19 Oct 2016 07:11:40 +0200 (CEST)
Received: from mail-it0-f51.google.com (mail-it0-f51.google.com [209.85.214.51])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 05D4B41C08B
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 07:11:39 +0200 (CEST)
Received: by mail-it0-f51.google.com with SMTP id 4so102345484itv.0
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 22:11:39 -0700 (PDT)
In-Reply-To: <c954507a960add0ae9410c19fd40eebc1fda0f95.1476708212.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 6:02 AM, Jiri Benc <jbenc@redhat.com> wrote:
> We'll need it to alter packets sent to ARPHRD_NONE interfaces.
>
> Change do_output() to use the actual L2 header size of the packet when
> deciding on the minimum cutlen. The assumption here is that what matters is
> not the output interface hard_header_len but rather the L2 header of the
> particular packet. For example, ARPHRD_NONE tunnels that encapsulate
> Ethernet should get at least the Ethernet header.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
