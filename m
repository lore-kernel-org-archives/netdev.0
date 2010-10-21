From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2 07/14] ethtool: Add support for vlan accleration.
Date: Thu, 21 Oct 2010 12:43:46 -0700
Message-ID: <AANLkTi=Ws6acYHszNKm0E2ur4AKoim+jBkmiaYvdsa9t@mail.gmail.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	<1287618974-4714-8-git-send-email-jesse@nicira.com>
	<4CBFB320.2060703@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:54780 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755037Ab0JUTns convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 15:43:48 -0400
Received: by gyg4 with SMTP id 4so212129gyg.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 12:43:48 -0700 (PDT)
In-Reply-To: <4CBFB320.2060703@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 20, 2010 at 8:27 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> On 10/20/2010 4:56 PM, Jesse Gross wrote:
>> Now that vlan acceleration is handled consistently regardless of usa=
ge,
>> it is possible to enable and disable it at will. =A0This adds suppor=
t for
>> Ethtool operations that change the offloading status for debugging
>> purposes, similar to other forms of hardware acceleration.
>>
>
> Jesse,
>
> Not sure if this is enough to get dynamic toggling like this
> dev->hard_header_len is set depending on offloads at init time in
> vlan_dev_init(). By changing this LL_RESERVED_SPACE won't work
> correctly and we end up having to call pskb_expand_head(). I think
> this might end up hurting performance.

That's a good point.

>
> That said I think I can probably get this working by fixing up the
> header_ops in vlan_dev.c. =A0And while I'm at it add a vlan_header_ca=
che
> and vlan_header_cache_update routines. I'll try to get something out
> tomorrow in the meantime nothing too bad is happening.

That sounds great, thanks.
