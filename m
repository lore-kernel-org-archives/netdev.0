From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6] if_vlan.h: fix compile errors
Date: Wed, 13 Apr 2011 04:03:57 -0700
Message-ID: <BANLkTimn2GfWs3tmoh+GRX6vX6tH9FpEyg@mail.gmail.com>
References: <1302690737-14524-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<20110413105758.GA2910@psychotron.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52278 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756970Ab1DMLD6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 07:03:58 -0400
Received: by fxm17 with SMTP id 17so355226fxm.19
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 04:03:57 -0700 (PDT)
In-Reply-To: <20110413105758.GA2910@psychotron.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2011 at 03:57, Jiri Pirko <jpirko@redhat.com> wrote:
> Thanks Jeff, this fix was already submitted by DaveM

Ah, ok.  I did not see anything in netdev patchworks and I did a
recent pull of Dave's net-next tree so I knew I had the latest.
Good to know it was caught, thanks Jiri.

>
> Wed, Apr 13, 2011 at 12:32:17PM CEST, jeffrey.t.kirsher@intel.com wro=
te:
>>The following commit generates compile errors becuase vlan_untag was =
defined
>>multiple times.
>>
>> =C2=A0 =C2=A0commit bcc6d47903612c3861201cc3a866fb604f26b8b2
>> =C2=A0 =C2=A0Author: Jiri Pirko <jpirko@redhat.com>
>> =C2=A0 =C2=A0Date: =C2=A0 Thu Apr 7 19:48:33 2011 +0000
>>
>> =C2=A0 =C2=A0net: vlan: make non-hw-accel rx path similar to hw-acce=
l
>>
>>Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>---
>> include/linux/if_vlan.h | =C2=A0 =C2=A02 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>>diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>>index 998b299..546d9d3 100644
>>--- a/include/linux/if_vlan.h
>>+++ b/include/linux/if_vlan.h
>>@@ -174,7 +174,7 @@ static inline bool vlan_do_receive(struct sk_buff=
 **skb)
>> =C2=A0 =C2=A0 =C2=A0 return false;
>> }
>>
>>-inline struct sk_buff *vlan_untag(struct sk_buff *skb)
>>+static inline struct sk_buff *vlan_untag(struct sk_buff *skb)
>> {
>> =C2=A0 =C2=A0 =C2=A0 return skb;
>> }
