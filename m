From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [RFC 1/2] net: Support getting/setting RX-FCS in drivers.
Date: Fri, 17 Jun 2011 09:36:31 +0200
Message-ID: <BANLkTikhUiVR-+DORohviSVTpQJLZQuTCQ@mail.gmail.com>
References: <1308285007-11302-1-git-send-email-greearb@candelatech.com> <1308285007-11302-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:48097 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755529Ab1FQHgw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 03:36:52 -0400
Received: by qyg14 with SMTP id 14so1181837qyg.19
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 00:36:51 -0700 (PDT)
In-Reply-To: <1308285007-11302-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/6/17  <greearb@candelatech.com>:
> From: Ben Greear <greearb@candelatech.com>
>
> This will allow us to enable/disable having the Ethernet
> frame checksum appended to the skb. =C2=A0Enabling this is
> useful when sniffing packets.
>
> In particular, this can be used to test logic that allows
> a NIC to receive all frames, even ones with bad checksums.

You want to silently run away from extending dev->features field? ;-)

Best Regards,
Micha=C5=82 Miros=C5=82aw
