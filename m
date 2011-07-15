From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6 00/22] vlan cleanup round1
Date: Sat, 16 Jul 2011 00:15:42 +0200
Message-ID: <CAHXqBFJiNx3N+Rs_dxMqSThN59kvmYauU=-mWvZEf9pUQ-MoZA@mail.gmail.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:44104 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540Ab1GOWQD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 18:16:03 -0400
Received: by qyk9 with SMTP id 9so965740qyk.19
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 15:16:02 -0700 (PDT)
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/15 Jiri Pirko <jpirko@redhat.com>:
> This patchset converts several drivers to new vlan model.
> Also kills several vlan helpers:
> vlan_hwaccel_receive_skb,
> lro_vlan_hwaccel_receive_frags,
> lro_vlan_hwaccel_receive_skb

It looks like most drivers that implement rx_add/kill_vid also need
bitmap recording all enabled VLANs. I think this could be done in
networking core for those devices in a generic way (set/clear before
corresponding rx_add/kill_vid call). The bitmap should be dynamically
allocated when needed (either on device registration time, or adding
first VLAN).

This might be out of scope for this cleanup, though.

Looks good otherwise.

Best Regards,
Micha=C5=82 Miros=C5=82aw
