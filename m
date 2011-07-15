From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 00/22] vlan cleanup round1
Date: Sat, 16 Jul 2011 01:07:19 +0200
Message-ID: <20110715230719.GB3499@minipsycho.orion>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
 <CAHXqBFJiNx3N+Rs_dxMqSThN59kvmYauU=-mWvZEf9pUQ-MoZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753564Ab1GOXH2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 19:07:28 -0400
Content-Disposition: inline
In-Reply-To: <CAHXqBFJiNx3N+Rs_dxMqSThN59kvmYauU=-mWvZEf9pUQ-MoZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jul 16, 2011 at 12:15:42AM CEST, mirqus@gmail.com wrote:
>2011/7/15 Jiri Pirko <jpirko@redhat.com>:
>> This patchset converts several drivers to new vlan model.
>> Also kills several vlan helpers:
>> vlan_hwaccel_receive_skb,
>> lro_vlan_hwaccel_receive_frags,
>> lro_vlan_hwaccel_receive_skb
>
>It looks like most drivers that implement rx_add/kill_vid also need
>bitmap recording all enabled VLANs. I think this could be done in
>networking core for those devices in a generic way (set/clear before
>corresponding rx_add/kill_vid call). The bitmap should be dynamically
>allocated when needed (either on device registration time, or adding
>first VLAN).

Right, I'm going to think about it. I might repost this patchset after
that, So Dave please do not apply right away, thanks.

Jirka
>
>This might be out of scope for this cleanup, though.
>
>Looks good otherwise.
>
>Best Regards,
>Micha=C5=82 Miros=C5=82aw
