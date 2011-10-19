From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: RE: [PATCH] ipvs: Remove unused variable "cs" from ip_vs_leave
 function.
Date: Wed, 19 Oct 2011 12:37:51 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903185@ESESSCMS0356.eemea.ericsson.se>
References: <1318967989-14076-1-git-send-email-krzysztof.wilczynski@linux.com>
 <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903183@ESESSCMS0356.eemea.ericsson.se>,<CAC52Y8ZvgBVC4_TEBFMALa-xU84PseV6w6sJO64ch+BdAqD2aA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Simon Horman <horms@verge.net.au>,
	Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pablo@netfilter.org" <pablo@netfilter.org>
To: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:52547 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511Ab1JSKhy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 06:37:54 -0400
In-Reply-To: <CAC52Y8ZvgBVC4_TEBFMALa-xU84PseV6w6sJO64ch+BdAqD2aA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>Hello,
>
>[...]
>> In my code there is another fix needed as well (todays net-next)
>> i.e.  usage od cs  "cs = ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd)"
>[...]
>
>Well spotted in terms of "net-next" branch and/or repository.
>
>In my case, I was working against "ipvs-next" using Simon's tree on
>github (I have made the fork when kernel.org facilities were not
>available at the time): https://github.com/horms/ipvs-next, and the
>code line you still appear to have in Dave's "net-next" (if that is
>the one) was amended in the following commit made against "ipvs-next":

Sorry, I didn't use that repo...
(waiting for ipvs return to kernel.org)

>
>
>commit 833656973cde30ba067a994c4802ebab6c9557ee
>Author: Simon Horman <horms@verge.net.au>
>Date:   Fri Sep 16 14:11:49 2011 +0900
>
>    ipvs: Remove unused return value of protocol state transitions
>
>    Acked-by: Julian Anastasov <ja@ssi.bg>
>    Acked-by Hans Schillstrom <hans@schillstrom.com>
>    Signed-off-by: Simon Horman <horms@verge.net.au>
>    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
>

>From what I can see Simon made a pull request and it was Acked by Pablo 28 Sep
http://www.spinics.net/lists/netfilter-devel/msg19742.html

I have not seen any output to Miller yet...
but I might be wrong in that case 


>
>It wasn't there when I went about cleaning unused declaration of "cs".
>I guess we have to make sure that everything between github (and
>repositories there) and kernel.org repositories like Dave's "net-next"
>align and holds water. Just by looking at some files, I can see that
>"net-next" is missing some commits.
>
>KW

Regards
Hans