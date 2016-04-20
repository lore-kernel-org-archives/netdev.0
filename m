From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 20:54:36 -0700
Message-ID: <5716FD7C.4080901@cumulusnetworks.com>
References: <20160419.143134.2014460805657420897.davem@davemloft.net> <1461091667.10638.229.camel@edumazet-glaptop3.roam.corp.google.com> <57168225.2040507@6wind.com> <20160419.195009.1052027353987244150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33236 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbcDTDyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 23:54:38 -0400
Received: by mail-pf0-f173.google.com with SMTP id 184so13676749pff.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 20:54:38 -0700 (PDT)
In-Reply-To: <20160419.195009.1052027353987244150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/19/16, 4:50 PM, David Miller wrote:
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue, 19 Apr 2016 21:08:21 +0200
>
>> Le 19/04/2016 20:47, Eric Dumazet a =E9crit :
>>> Since we want to use this in other places, we could define a helper=
=2E
>>>
>>> nla_align_64bit(skb, attribute)  or something.
>> Yes, with the corresponding nla_total_size_64bit()
> Good, idea, committed the following:
>
> Roopa, please use these helpers in your RTM_GETSTATS patch.

will do.
>
> Thank you.
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [PATCH] net: Add helpers for 64-bit aligning netlink attributes.
>
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Suggested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> =20
these look really nice.

Thanks!
