From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/8] vxge: convert to SKB paged frag API.
Date: Thu, 6 Oct 2011 23:28:59 +0200
Message-ID: <CAHXqBFKSUqTyU=J5yefyv54k6J-gS5BsfQBJP2O=u8QOR+jTCw@mail.gmail.com>
References: <1317884756.24742.13.camel@dagon.hellion.org.uk>
 <1317916822.21903.252.camel@zakaz.uk.xensource.com> <CAHXqBFJsGcAdH0zFS_Gd34oR3Ov6ssbXRMzK-KrnSxq8c3=WNg@mail.gmail.com>
 <20111006.171519.797156146863050743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian.Campbell@citrix.com, netdev@vger.kernel.org, jdmason@kudzu.us
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:35532 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755903Ab1JFV3T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 17:29:19 -0400
Received: by ggnv2 with SMTP id v2so2157619ggn.19
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2011 14:29:19 -0700 (PDT)
In-Reply-To: <20111006.171519.797156146863050743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/6 David Miller <davem@davemloft.net>:
> From: Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>
> Date: Thu, 6 Oct 2011 22:45:57 +0200
>> There's a catch there, though:
> =C2=A0..
>> dma_mapping_error() takes struct device *, so those changes should b=
e:
>>
>> dma_mapping_error(&tp->pdev->dev, mapping)
>>
>> (Like skb_frag_dma_map()'s first argument).
> Why don't you take a look at what I committed and pushed out
> (hint: I fixed it up when I saw the build warnings)?

You were just quicker than me or Ian on this one. We'll be faster next =
time.

Best Regards,
Micha=C5=82 Miros=C5=82aw
