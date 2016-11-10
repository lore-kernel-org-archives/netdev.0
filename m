From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 5/7] vxlan: simplify RTF_LOCAL handling.
Date: Wed, 9 Nov 2016 19:34:12 -0800
Message-ID: <CAOrHB_BTV8cAgDLnK89eyZbQnkfbBLmj_zWRom2xrUPayLDBGQ@mail.gmail.com>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
 <1478371557-71888-6-git-send-email-pshelar@ovn.org> <20161109175322.57c9b860@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:37014 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753532AbcKJDeQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 22:34:16 -0500
Received: from mfilter31-d.gandi.net (mfilter31-d.gandi.net [217.70.178.162])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 38E6C41C08B
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 04:34:15 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter31-d.gandi.net (mfilter31-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id qfGmB1ezm2ay for <netdev@vger.kernel.org>;
        Thu, 10 Nov 2016 04:34:13 +0100 (CET)
Received: from mail-it0-f42.google.com (mail-it0-f42.google.com [209.85.214.42])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id AE40E41C080
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 04:34:13 +0100 (CET)
Received: by mail-it0-f42.google.com with SMTP id e187so242450749itc.0
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 19:34:13 -0800 (PST)
In-Reply-To: <20161109175322.57c9b860@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 9, 2016 at 8:53 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Sat,  5 Nov 2016 11:45:55 -0700, Pravin B Shelar wrote:
>> +static int check_route_rtf_local(struct sk_buff *skb, struct net_device *dev,
>> +                              struct vxlan_dev *vxlan, union vxlan_addr *daddr,
>> +                              __be32 dst_port, __be32 vni, struct dst_entry *dst,
>> +                              u32 rt_flags)
>
> It's not just checking, it's also bypassing encapsulation if the check
> is successful. Would be good to use a name that suggests this effect,
> e.g. encap_bypass_if_local (I know, not a nice name) or something.
>

I am fine with this name. I will change the patch.
