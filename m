From: Lance Richardson <lrichard@redhat.com>
Subject: Re: Faster TCP keepalive
Date: Mon, 26 Jun 2017 15:21:37 -0400 (EDT)
Message-ID: <269605029.27220992.1498504897374.JavaMail.zimbra@redhat.com>
References: <20170623195817.GA13904@ssuryaputra-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Suryaputra Lin <stephen.suryaputra.lin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36778 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751427AbdFZTVn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 15:21:43 -0400
In-Reply-To: <20170623195817.GA13904@ssuryaputra-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Stephen Suryaputra Lin" <stephen.suryaputra.lin@gmail.com>
> To: netdev@vger.kernel.org
> Sent: Friday, 23 June, 2017 3:58:17 PM
> Subject: Faster TCP keepalive
> 
> Greetings,
> 
> I'm writing this to probe if there has been thoughts or efforts in
> allowing sub-second TCP keep alive interval? One application is for TCP
> connections between IP hosts connected by an internal backplane where a
> faster detection is a necessity and the increased traffic can be
> accommodated.
> 
> Suggestions on other ways to quickly tearing down TCP connections to a
> rebooted host in the application above are welcomed.
> 

For quickly tearing down TCP connections to a host that has been rebooted,
avoiding e.g. waiting for TCP max retransmit count to be reached), you
could use SOCK_DESTROY (as e.g. iproute2's "ss -K [ FILTER ]" does).

Regards,

  Lance

> Thank you,
> 
> Stephen.
> 
