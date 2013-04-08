From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 22:03:33 +0400
Message-ID: <51630675.8040608@cogentembedded.com>
References: <20130408154519.18177.57709.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Miroslav Vadkerti <mvadkert@redhat.com>
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:64261 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762866Ab3DHSEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 14:04:40 -0400
Received: by mail-lb0-f171.google.com with SMTP id v10so5973339lbd.2
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 11:04:38 -0700 (PDT)
In-Reply-To: <20130408154519.18177.57709.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/08/2013 07:45 PM, Paul Moore wrote:

> Commit 90ba9b1986b5ac4b2d184575847147ea7c4280a2

    Please also specify that commit's summary line in parens
(DaveM seems to also require double quotes inside the parens).

> converted
> tcp_make_synack() to use alloc_skb() directly instead of calling
> sock_wmalloc(), the goal being the elimination of two atomic
> operations.  Unfortunately, in doing so the change broke certain
> SELinux/NetLabel configurations by no longer correctly assigning
> the sock to the outgoing packet.
>
> This patch fixes this regression by doing the skb->sk assignment
> directly inside tcp_make_synack().
>
> Reported-by: Miroslav Vadkerti <mvadkert@redhat.com>
> Signed-off-by: Paul Moore <pmoore@redhat.com>

WBR, Sergei
