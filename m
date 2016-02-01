From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v1 06/10] tipc: fix connection abort when
 receiving invalid cancel request
Date: Mon, 1 Feb 2016 16:21:58 +0300
Message-ID: <56AF5BF6.1030108@cogentembedded.com>
References: <1454319883-16031-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
 <1454319883-16031-7-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net, jon.maloy@ericsson.com,
	maloy@donjonn.com, ying.xue@windriver.com
To: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:35914 "EHLO
	mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932173AbcBANWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 08:22:01 -0500
Received: by mail-lf0-f44.google.com with SMTP id 78so47434198lfy.3
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 05:22:01 -0800 (PST)
In-Reply-To: <1454319883-16031-7-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/1/2016 12:44 PM, Parthasarathy Bhuvaragan wrote:

> Until now, the subscribers endianness for a subscription
> create/cancel request is determined as:
>      swap = !(s->filter & (TIPC_SUB_PORTS | TIPC_SUB_SERVICE))
> The checks are performed only for port/service subscriptions.
>
> The swap calculation is incorrectly if the filter in the subscription

    Incorrect.

> cancellation request is set to TIPC_SUB_CANCEL (its a malformed

    It's.

> cancel request, as the corresponding subscription create filter
> is missing).
> Thus, the check if the request is for cancellation fails and the
> request is treated as a subscription create request. The
> subscription creation fails as the request is illegal, which
> terminates this connection.
>
> In this commit we determine the endianness by including
> TIPC_SUB_CANCEL, which will set swap correctly and the
> request is processed as a cancel request.

    Cancellation, maybe, as it was worded above?

> Acked-by: Ying Xue <ying.xue@windriver.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
[...]

MBR, Sergei
