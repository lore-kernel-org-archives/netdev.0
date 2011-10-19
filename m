From: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
Subject: Re: [PATCH] ipvs: Remove unused variable "cs" from ip_vs_leave function.
Date: Wed, 19 Oct 2011 11:13:51 +0100
Message-ID: <CAC52Y8ZvgBVC4_TEBFMALa-xU84PseV6w6sJO64ch+BdAqD2aA@mail.gmail.com>
References: <1318967989-14076-1-git-send-email-krzysztof.wilczynski@linux.com> <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903183@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Horman <horms@verge.net.au>,
	Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?Hans_Schillstr=C3=B6m?= <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:54405 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978Ab1JSKOW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 06:14:22 -0400
Received: by qyk4 with SMTP id 4so4184668qyk.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 03:14:21 -0700 (PDT)
In-Reply-To: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903183@ESESSCMS0356.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

[...]
> In my code there is another fix needed as well (todays net-next)
> i.e. =C2=A0usage od cs =C2=A0"cs =3D ip_vs_set_state(cp, IP_VS_DIR_IN=
PUT, skb, pd)"
[...]

Well spotted in terms of "net-next" branch and/or repository.

In my case, I was working against "ipvs-next" using Simon's tree on
github (I have made the fork when kernel.org facilities were not
available at the time): https://github.com/horms/ipvs-next, and the
code line you still appear to have in Dave's "net-next" (if that is
the one) was amended in the following commit made against "ipvs-next":


commit 833656973cde30ba067a994c4802ebab6c9557ee
Author: Simon Horman <horms@verge.net.au>
Date:   Fri Sep 16 14:11:49 2011 +0900

    ipvs: Remove unused return value of protocol state transitions

    Acked-by: Julian Anastasov <ja@ssi.bg>
    Acked-by Hans Schillstrom <hans@schillstrom.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>


It wasn't there when I went about cleaning unused declaration of "cs".
I guess we have to make sure that everything between github (and
repositories there) and kernel.org repositories like Dave's "net-next"
align and holds water. Just by looking at some files, I can see that
"net-next" is missing some commits.

KW
