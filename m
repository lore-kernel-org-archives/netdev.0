From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/3] tipc: reduce transmission rate of reset
 messages when link is down
Date: Tue, 5 Apr 2016 23:07:22 +0300
Message-ID: <57041AFA.5090702@cogentembedded.com>
References: <1459873255-32354-1-git-send-email-jon.maloy@ericsson.com>
 <1459873255-32354-4-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: Jon Maloy <jon.maloy@ericsson.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:34335 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbcDEUH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 16:07:27 -0400
Received: by mail-lf0-f50.google.com with SMTP id j11so18633520lfb.1
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 13:07:26 -0700 (PDT)
In-Reply-To: <1459873255-32354-4-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/05/2016 07:20 PM, Jon Maloy wrote:

> When a link is down, it will continuously try to re-establish contact
> with the peer by sending out a RESET or and ACTIVATE message at each

    And/or?

> timeout interval. The default value for this interval is currently
> 375 ms. This is wasteful, and may become a problem in very large
> clusters with dozens or hundereds of nodes being down simultaneously.

    Hundreds.

> We now introduce a simple backoff algorithm for these cases. The
> first five messages are sent at default rate; thereafter a message
> is sent only each 16't timer interval.

    16th?

> This will cover the vast majority of link recyling cases, since the

    Recycling.

> endpoint starting last will transmit at the higher speed, and the link
> should normally be established well be before the rate needs to be
> reduced.
>
> The only case where we will see a degradation of link re-establishment
> is when the endpoins remain intact, and a glitch in the transmission

    Endpoints.

> media is causing the link reset. We will then experience a worst-case
> re-establishing time of 6 seconds, something we deem acceptable.
>
> Acked-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
[...]

MBR, Sergei
