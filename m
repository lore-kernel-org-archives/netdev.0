From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH v3 net-next 1/3] openvswitch: Add a missing break statement.
Date: Mon, 19 Dec 2016 17:07:36 -0800
Message-ID: <4D3C1D53-D36E-4C31-999F-83E242A44E5B@ovn.org>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org> <CAOrHB_By4AoojkiA33bP3GT7ABsdZfJkp9j2kGpno76j9cqXug@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Benc <jbenc@redhat.com>, Eric Garver <e@erig.me>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34472 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933063AbcLTBHl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 20:07:41 -0500
Received: by mail-it0-f65.google.com with SMTP id 75so12311202ite.1
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 17:07:40 -0800 (PST)
In-Reply-To: <CAOrHB_By4AoojkiA33bP3GT7ABsdZfJkp9j2kGpno76j9cqXug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Dec 13, 2016, at 9:07 PM, Pravin Shelar <pshelar@ovn.org> wrote:
> 
> On Tue, Nov 29, 2016 at 3:30 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
>> Add a break statement to prevent fall-through from
>> OVS_KEY_ATTR_ETHERNET to OVS_KEY_ATTR_TUNNEL.  Without the break
>> actions setting ethernet addresses fail to validate with log messages
>> complaining about invalid tunnel attributes.
>> 
>> Fixes: 0a6410fbde ("openvswitch: netlink: support L3 packets")
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
>> Acked-by: Pravin B Shelar <pshelar@ovn.org>
>> Acked-by: Jiri Benc <jbenc@redhat.com>
> 
> Hi Jarno,
> Since this is straight forward patch. can you send it separately so
> that we can get it merged soon?
> 

I just did, against net. You’ll take over the rest?

  Jarno

> Thanks,
> Pravin.
