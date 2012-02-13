From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v3 02/16] e100: Support RXFCS feature flag.
Date: Mon, 13 Feb 2012 09:19:33 -0800
Message-ID: <4F394625.9010702@candelatech.com>
References: <1328922274-23993-1-git-send-email-greearb@candelatech.com>  <1328922274-23993-3-git-send-email-greearb@candelatech.com> <1328980060.5661.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51742 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755411Ab2BMRTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 12:19:42 -0500
In-Reply-To: <1328980060.5661.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2012 09:07 AM, Eric Dumazet wrote:
> Le vendredi 10 f=C3=A9vrier 2012 =C3=A0 17:04 -0800, greearb@candelat=
ech.com a
> =C3=A9crit :
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This allows e100 to be configured to append the
>> Ethernet FCS to the skb.
>>
>> Useful for sniffing networks.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>> ---
>
> Did you try this patch with 8021Q frames ?
>
> You must change
>
> #define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)
>
> to :
>
> #define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN + ETH_FC=
S_LEN)
>
> And also on various spots where VLAN_ETH_FRAME_LEN is used in this
> driver...
>
> nic->blank_rfd.size =3D cpu_to_le16(VLAN_ETH_FRAME_LEN);

Thanks for the review.  I did not try it with VLAN frames.  It may
be a few days until I can get this done and test it well....

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
