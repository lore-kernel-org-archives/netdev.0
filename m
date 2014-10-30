From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net] gre: Fix regression in gretap TSO support
Date: Thu, 30 Oct 2014 08:32:13 -0700
Message-ID: <CA+mtBx9Mc41qbFCw+qYiUoz_8hfoyjX=nooaH2N_f8zfLYUnPQ@mail.gmail.com>
References: <20141030032430.4452.46388.stgit@ahduyck-workstation.home>
	<CALnjE+oK-O-PJH_u50HqQQLnvh+GyeCnv6tNQf5qzL0o1RiPQg@mail.gmail.com>
	<CADVnQykSY_Q3HL0T1uNO4iUheWTpTsLLF7gCnM4SbJyGp3x6Wg@mail.gmail.com>
	<54524B6A.3000503@redhat.com>
	<CA+mtBx_AAexNNktyZDFFZwqzgEh_FJbdekvtYVLn7cc2AGLFqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neal Cardwell <ncardwell@google.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:42249 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161153AbaJ3PcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 11:32:14 -0400
Received: by mail-ie0-f170.google.com with SMTP id tp5so5544783ieb.15
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 08:32:13 -0700 (PDT)
In-Reply-To: <CA+mtBx_AAexNNktyZDFFZwqzgEh_FJbdekvtYVLn7cc2AGLFqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm not sure I understand this. We always use inner mac header in
> __skb_udp_tunnel_segment for computing tunnel length and don't
> distinguish between Ethernet or IP encapsulation. Presumably, in the
> case of IP encapsulation inner mac header is equal to inner network
> header. Why is this different for GRE?
>

Using skb_inner_mac_header seems to work okay for IP encapsulation.
I'll post the path momentarily.

Tom


> Thanks,
> Tom
>
>> Thanks,
>>
>> Alex
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
