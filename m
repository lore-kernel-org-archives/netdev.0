From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v3 4/7] vxlan: improve vxlan route lookup checks.
Date: Thu, 17 Nov 2016 21:30:37 -0800
Message-ID: <CAOrHB_BNei3ZKAmbNWNRvYVnb3ySKKn4nncZRqr8RoANbBp1DQ@mail.gmail.com>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
 <1479098638-4921-5-git-send-email-pshelar@ovn.org> <20161115153934.363e176d@griffin>
 <063D6719AE5E284EB5DD2968C1650D6DB0222355@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Benc <jbenc@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:44141 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751222AbcKRFam (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 00:30:42 -0500
Received: from mfilter14-d.gandi.net (mfilter14-d.gandi.net [217.70.178.142])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 9C7DB17209F
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 06:30:40 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter14-d.gandi.net (mfilter14-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id hPVaTuw70dCq for <netdev@vger.kernel.org>;
        Fri, 18 Nov 2016 06:30:39 +0100 (CET)
Received: from mail-it0-f46.google.com (mail-it0-f46.google.com [209.85.214.46])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 3B1661720B2
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 06:30:38 +0100 (CET)
Received: by mail-it0-f46.google.com with SMTP id y23so14550136itc.0
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 21:30:38 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0222355@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2016 at 2:17 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Of Jiri Benc
>> Sent: 15 November 2016 14:40
>> On Sun, 13 Nov 2016 20:43:55 -0800, Pravin B Shelar wrote:
>> > @@ -1929,8 +1951,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>> >     union vxlan_addr *src;
>> >     struct vxlan_metadata _md;
>> >     struct vxlan_metadata *md = &_md;
>> > -   struct dst_entry *ndst = NULL;
>> >     __be16 src_port = 0, dst_port;
>> > +   struct dst_entry *ndst = NULL;
>> >     __be32 vni, label;
>> >     __be16 df = 0;
>> >     __u8 tos, ttl;
>>
>> This looks kind of arbitrary. You might want to remove this hunk or
>> merge it to patch 3.
>
> Worse than arbitrary, it adds 4 bytes of pad on 64bit systems.
>
OK. I will send out a patch.
But this is not real issue in vxlan module today ;)
