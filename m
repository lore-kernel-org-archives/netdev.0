From: enh <enh@google.com>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Mon, 3 May 2010 23:19:22 -0700
Message-ID: <AANLkTingTdmhyJhENb9AYDjUT7m_-yQflw5-gJqIA9iw@mail.gmail.com>
References: <AANLkTikUArEWFhsxpJGCbOPtvQATBKztP0jhZTTsdx7-@mail.gmail.com>
	 <4BDF8387.4000303@hp.com>
	 <20100503.230553.200626786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:23294 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009Ab0EDGT2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 02:19:28 -0400
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [10.3.21.6])
	by smtp-out.google.com with ESMTP id o446JRCj027564
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 23:19:27 -0700
Received: from ywh1 (ywh1.prod.google.com [10.192.8.1])
	by hpaq6.eem.corp.google.com with ESMTP id o446JP0e029562
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 23:19:25 -0700
Received: by ywh1 with SMTP id 1so2678340ywh.30
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 23:19:25 -0700 (PDT)
In-Reply-To: <20100503.230553.200626786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 3, 2010 at 23:05, David Miller <davem@davemloft.net> wrote:
> From: Brian Haley <brian.haley@hp.com>
> Date: Mon, 03 May 2010 22:16:39 -0400
>
>> It looks like a bug to me, feel free to send along a patch :)
>
> Is it? =C2=A0The quoted text is only about setting the value and what
> effect setting -1 or whatever has.
>
> For getting the value, the behavior described sounds just fine.
>
> The default for a socket is whatever the kernel-wide default is.

for the *unicast* hops, a part of the RFC i didn't quote says:

   If the [IPV6_UNICAST_HOPS] option is not set, the
   system selects a default value.

but for the *multicast* hops, which is what i'm talking about, this
part of the quoted text seems pretty definitive:

           If IPV6_MULTICAST_HOPS is not set, the default is 1
           (same as IPv4 today)

this is what my test shows isn't true of linux; linux reuses its
unicast default instead.

--=20
Elliott Hughes - http://who/enh - http://jessies.org/~enh/
