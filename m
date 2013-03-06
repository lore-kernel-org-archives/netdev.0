From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH 3/3 net-next] tcp: implement RFC5682 F-RTO
Date: Wed, 6 Mar 2013 13:34:10 -0800
Message-ID: <CAGK4HS_Dguo846dT_hAocnSX2RFvg71Bx-Tu_Z8zm9HXaV2CcQ@mail.gmail.com>
References: <1362603130-16501-1-git-send-email-ycheng@google.com>
	<1362603130-16501-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com, ilpo.jarvinen@cs.helsinki.fi,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f41.google.com ([209.85.128.41]:39836 "EHLO
	mail-qe0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551Ab3CFVl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 16:41:27 -0500
Received: by mail-qe0-f41.google.com with SMTP id 6so5753707qeb.0
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 13:41:27 -0800 (PST)
In-Reply-To: <1362603130-16501-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6 March 2013 12:52, Yuchung Cheng <ycheng@google.com> wrote:
> This patch implements F-RTO (foward RTO recovery):
>

You may want to fix the following checkpatch errors:

ERROR: trailing whitespace
#129: FILE: net/ipv4/tcp_input.c:1893:
+^I/* F-RTO RFC5682 sec 3.1 step 1: retransmit SND.UNA if no previous $

ERROR: trailing whitespace
#184: FILE: net/ipv4/tcp_input.c:2694:
+^I^I^I/* Step 3.b. A timeout is spurious if not all data are $

ERROR: trailing whitespace
#216: FILE: net/ipv4/tcp_input.c:2722:
+^I^I/* A Reno DUPACK means new data in F-RTO step 2.b above are $


-Vijay
