From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v12 6/9] openvswitch: netlink: support L3 packets
Date: Thu, 20 Oct 2016 21:20:29 -0700
Message-ID: <CAOrHB_A1O5BTLtL=AiGB8b9hfzK8n7CjceJTcmWQBH7abm3iVw@mail.gmail.com>
References: <cover.1476708212.git.jbenc@redhat.com> <8bb825e9a05a96a352dafddccfc49392f4f0813c.1476708213.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:47320 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751686AbcJUEUf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 00:20:35 -0400
Received: from mfilter11-d.gandi.net (mfilter11-d.gandi.net [217.70.178.131])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 8EFBAFB882
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 06:20:32 +0200 (CEST)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter11-d.gandi.net (mfilter11-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id vFhc4xUGkS58 for <netdev@vger.kernel.org>;
        Fri, 21 Oct 2016 06:20:31 +0200 (CEST)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 0D8FFFB881
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 06:20:30 +0200 (CEST)
Received: by mail-it0-f41.google.com with SMTP id k64so44850965itb.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 21:20:30 -0700 (PDT)
In-Reply-To: <8bb825e9a05a96a352dafddccfc49392f4f0813c.1476708213.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 6:02 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Extend the ovs flow netlink protocol to support L3 packets. Packets without
> OVS_KEY_ATTR_ETHERNET attribute specify L3 packets; for those, the
> OVS_KEY_ATTR_ETHERTYPE attribute is mandatory.
>
> Push/pop vlan actions are only supported for Ethernet packets.
>
> Based on previous versions by Lorand Jakab and Simon Horman.
>
> Signed-off-by: Lorand Jakab <lojakab@cisco.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
