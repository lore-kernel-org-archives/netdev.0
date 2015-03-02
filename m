From: Madhu Challa <challa@noironetworks.com>
Subject: Re: [PATCH net-next v5 0/2] Multicast group join/leave at ip level
Date: Mon, 2 Mar 2015 10:31:05 -0800
Message-ID: <CAN_zqfMJKp2P3y1n=2rNLAKvLNJaeseYAkWZJLiij1gxLOLsdw@mail.gmail.com>
References: <1424887115-3483-1-git-send-email-challa@noironetworks.com>
	<20150227.162611.864498157750734820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:42782 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbbCBSbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 13:31:06 -0500
Received: by pdbfl12 with SMTP id fl12so10349342pdb.9
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 10:31:05 -0800 (PST)
In-Reply-To: <20150227.162611.864498157750734820.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 1:26 PM, David Miller <davem@davemloft.net> wrote:
> From: Madhu Challa <challa@noironetworks.com>
> Date: Wed, 25 Feb 2015 09:58:33 -0800
>
>> This series enables configuring multicast group join/leave at ip level
>> by extending the "ip address" command.
>>
>> It adds a new control socket mc_autojoin_sock and ifa_flag IFA_F_MCAUTOJOIN
>> to invoke the corresponding igmp group join/leave api.
>>
>> Since the igmp group join/leave api takes the rtnl_lock the code had to
>> be refactored by adding a shim layer prefixed by __ that can be invoked
>> by code that already has the rtnl_lock. This way we avoid proliferation of
>> work queues.
>>
>> The first patch in this series does the refactoring for igmp v6.
>> Its based on igmp v4 changes that were added by Eric Dumazet.
>>
>> The second patch in this series does the group join/leave based on the
>> setting of the IFA_F_MCAUTOJOIN flag.
>
> Applied, but I'm wondering how many hacks we are going to add to the
> tree simply because openvswitch does all of it's stuff with non-native
> tunneling devices...

Thanks David. I will look into what Thomas suggested so we can avoid
these workarounds.

Thanks.
