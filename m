From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next 0/3] IPComp fixes
Date: Fri, 6 Dec 2013 17:58:30 +0800
Message-ID: <52A19FC6.8060107@windriver.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:55779 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961Ab3LFJ63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 04:58:29 -0500
In-Reply-To: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hallo, Steffen

Do I need to resend this IPcomp patch set for review?

Thanks :)

On 2013=E5=B9=B411=E6=9C=8828=E6=97=A5 10:52, Fan Du wrote:
> Hi,
>
> This patchset includes bug fix focusing on IPComp mainly, which addre=
sses
> IPComp Compression Parameter Index(CPI, 16bits of 32bits SPI value) p=
roblem.
>
> And other issue is the compression part, undesirable packet will not =
be
> compressed, and then send into wire, this packet will be dropped by p=
olicy
> checking in the receiver side.
>
> Fan Du (3):
>    xfrm: check user specified spi for IPComp
>    xfrm: clamp down spi range for IPComp when allocating spi
>    xfrm: Restrict "level use" for IPComp configuration
>
>   net/key/af_key.c      |    6 ++++++
>   net/xfrm/xfrm_state.c |   13 +++++++++++++
>   net/xfrm/xfrm_user.c  |    7 ++++++-
>   3 files changed, 25 insertions(+), 1 deletion(-)
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan fan
