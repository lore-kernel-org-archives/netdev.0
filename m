From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH 3/3 net-next] tcp: implement RFC5682 F-RTO
Date: Sat, 9 Mar 2013 11:13:06 -0800
Message-ID: <CAK6E8=fCpmtY2Sn3N1cGw2y-UP5bx6ztE+j=oaGsg8tUi0DAwQ@mail.gmail.com>
References: <1362603130-16501-1-git-send-email-ycheng@google.com>
 <1362603130-16501-3-git-send-email-ycheng@google.com> <CAGK4HS_Dguo846dT_hAocnSX2RFvg71Bx-Tu_Z8zm9HXaV2CcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	ilpo.jarvinen@cs.helsinki.fi, netdev <netdev@vger.kernel.org>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:42445 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737Ab3CITN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 14:13:28 -0500
Received: by mail-la0-f44.google.com with SMTP id eb20so2729422lab.17
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 11:13:26 -0800 (PST)
In-Reply-To: <CAGK4HS_Dguo846dT_hAocnSX2RFvg71Bx-Tu_Z8zm9HXaV2CcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 6, 2013 at 1:34 PM, Vijay Subramanian
<subramanian.vijay@gmail.com> wrote:
> On 6 March 2013 12:52, Yuchung Cheng <ycheng@google.com> wrote:
>> This patch implements F-RTO (foward RTO recovery):
>>
>
> You may want to fix the following checkpatch errors:
Sorry about these. Will respin the patch after Ilpo's review.

>
> ERROR: trailing whitespace
> #129: FILE: net/ipv4/tcp_input.c:1893:
> +^I/* F-RTO RFC5682 sec 3.1 step 1: retransmit SND.UNA if no previous $
>
> ERROR: trailing whitespace
> #184: FILE: net/ipv4/tcp_input.c:2694:
> +^I^I^I/* Step 3.b. A timeout is spurious if not all data are $
>
> ERROR: trailing whitespace
> #216: FILE: net/ipv4/tcp_input.c:2722:
> +^I^I/* A Reno DUPACK means new data in F-RTO step 2.b above are $
>
>
> -Vijay
