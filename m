From: pravin shelar <pshelar@ovn.org>
Subject: Re: [ovs-dev] [PATCH net-next v21 3/4] openvswitch: 802.1AD Flow
 handling, actions, vlan parsing, netlink attributes
Date: Fri, 2 Sep 2016 15:21:34 -0700
Message-ID: <CAOrHB_B+y5JxVEQkNRMvcHqA3teXUf7FvRgD33FORio3PVojmQ@mail.gmail.com>
References: <1472762727-25844-1-git-send-email-e@erig.me> <1472762727-25844-4-git-send-email-e@erig.me>
 <CAOrHB_A6Twwp+S514orUZ5RaKS1hGXgc1uUi7Lj8dxPQrk_sxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Thomas F Herbert <thomasfherbert@gmail.com>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:42263 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751271AbcIBWVj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 18:21:39 -0400
Received: from mfilter23-d.gandi.net (mfilter23-d.gandi.net [217.70.178.151])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 71DF7172097
        for <netdev@vger.kernel.org>; Sat,  3 Sep 2016 00:21:37 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter23-d.gandi.net (mfilter23-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id Pf49syWy0tpR for <netdev@vger.kernel.org>;
        Sat,  3 Sep 2016 00:21:36 +0200 (CEST)
Received: from mail-it0-f45.google.com (mail-it0-f45.google.com [209.85.214.45])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id DF47D172095
        for <netdev@vger.kernel.org>; Sat,  3 Sep 2016 00:21:35 +0200 (CEST)
Received: by mail-it0-f45.google.com with SMTP id e124so13418851ith.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 15:21:35 -0700 (PDT)
In-Reply-To: <CAOrHB_A6Twwp+S514orUZ5RaKS1hGXgc1uUi7Lj8dxPQrk_sxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 2, 2016 at 2:42 PM, pravin shelar <pshelar@ovn.org> wrote:
> On Thu, Sep 1, 2016 at 1:45 PM, Eric Garver <e@erig.me> wrote:
>> Add support for 802.1ad including the ability to push and pop double
>> tagged vlans. Add support for 802.1ad to netlink parsing and flow
>> conversion. Uses double nested encap attributes to represent double
>> tagged vlan. Inner TPID encoded along with ctci in nested attributes.
>>
>> This is based on Thomas F Herbert's original v20 patch. I made some
>> small clean ups and bug fixes.
>>
>> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
>> Signed-off-by: Eric Garver <e@erig.me>
>

checkpatch.pl is also not happy with the patch, It found bunch of issues.

./scripts/checkpatch.pl
0003-openvswitch-802.1AD-Flow-handling-actions-vlan-parsi.patch
...
...
total: 6 errors, 9 warnings, 1 checks, 460 lines checked
