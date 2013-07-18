From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [DISCUSSION] rt6i_genid
Date: Thu, 18 Jul 2013 11:13:20 +0200
Message-ID: <51E7B1B0.3000109@6wind.com>
References: <51E75F82.4080300@windriver.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:49629 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070Ab3GRJNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 05:13:24 -0400
Received: by mail-we0-f180.google.com with SMTP id w56so2665530wes.39
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 02:13:23 -0700 (PDT)
In-Reply-To: <51E75F82.4080300@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/07/2013 05:22, Fan Du a =C3=A9crit :
> Hello Nicolas
>
> Commit 6f3118b571b8a4c06c7985dc3172c3526cb86253: "ipv6: use net->rt_g=
enid to
> check dst validity"
> makes ip6_dst_check to check rt6i_genid against with struct net->rt_g=
enid,
> As a matter of fact, struct net->rt_genid could only be modified by t=
wo places,
> first is adding/delete IPv4 address, second is inserting new XFRM pol=
icy.
>
> Is there any other considerations that adding/deleting IPv4 address w=
ould
> invalid all IPv6 dst
> as well? because I'm working a patch which actually depends on the re=
sult of
> this question.
No, the goal was to cover the IPsec case, ie invalidate dst entries whe=
n an xfrm=20
policy is inserted/deleted.


Regards,
Nicolas
