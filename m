From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next v7 0/4] Refactor vxlan and l2tp to use common UDP
 tunnel APIs
Date: Mon, 15 Sep 2014 11:41:55 -0700
Message-ID: <CACzMAJKc=W-M6qrDqRXSNSqKhJJ2wO_TWQB2Ym0+7LhfdN4dhg@mail.gmail.com>
References: <1410777267-28237-1-git-send-email-azhou@nicira.com>
	<CAJ3xEMh4fceTRh7B4dLxM93eyi9bASaD2Uor+p+BVWHi34VeuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:40201 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754078AbaIOSl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 14:41:56 -0400
Received: by mail-oi0-f53.google.com with SMTP id x69so2759845oia.26
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 11:41:55 -0700 (PDT)
In-Reply-To: <CAJ3xEMh4fceTRh7B4dLxM93eyi9bASaD2Uor+p+BVWHi34VeuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

O.K. I will add Vn-1 -> Vn change tracking on the next patch. The
cover letter has the same text as V5. Sorry for dropping them.

On Mon, Sep 15, 2014 at 5:54 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Sep 15, 2014 at 1:34 PM, Andy Zhou <azhou@nicira.com> wrote:
>
> Hi Andy,
>
> It's a bit hard to track/review a series with empty cover letter and
> no Vn-1 --> Vn change tracking... can you please
> add it? no need to re-spin V8 just for that, you can reply here. BTW
> You did had non-empty cover letter in V5
>
> Or.
>
>> Andy Zhou (4):
>>   udp_tunnel: Seperate ipv6 functions into its own file.
>>   udp-tunnel: Expand UDP tunnel APIs
>>   vxlan: Refactor vxlan driver to make use of the common UDP tunnel
>>     functions.
>>   l2tp: Refactor l2tp core driver to make use of the common UDP tunnel
>>     functions
>>
>>  drivers/net/vxlan.c       |  105 ++++++++--------------------------
>>  include/net/udp_tunnel.h  |   83 ++++++++++++++++++++++++++-
>>  net/ipv4/udp_tunnel.c     |  138 ++++++++++++++++++++++++---------------------
>>  net/ipv6/Makefile         |    1 +
>>  net/ipv6/ip6_udp_tunnel.c |  105 ++++++++++++++++++++++++++++++++++
>>  net/l2tp/l2tp_core.c      |   24 ++++----
>>  6 files changed, 292 insertions(+), 164 deletions(-)
>>  create mode 100644 net/ipv6/ip6_udp_tunnel.c
>>
>> --
>> 1.7.9.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
