From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/3] Socket destruction events via netlink
 sock_diag
Date: Mon, 15 Jun 2015 13:28:25 -0700
Message-ID: <1434400105.27504.141.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434381980-20588-1-git-send-email-kraig@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, mleitner@redhat.com,
	stephen@networkplumber.org, davem@davemloft.net,
	ebiederm@xmission.net, tgraf@suug.ch, xemul@openvz.org
To: Craig Gallek <kraig@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:33905 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864AbbFOU21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 16:28:27 -0400
Received: by iebmu5 with SMTP id mu5so70547616ieb.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 13:28:26 -0700 (PDT)
In-Reply-To: <1434381980-20588-1-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-15 at 11:26 -0400, Craig Gallek wrote:
> This series extends the netlink sock_diag interface to broadcast
> socket information as they are being destroyed.  The current
> interface is poll based and can not be used to retreive information
> about sockets that are destroyed between poll intervals.
> 
> Only inet sockets are broadcast in this implementation, but other
> families could easily be added as needed in the future.
> 
> If this patch set is accepted, a follow-up patch to the ss utility
> in the iproute2 suite will also be submitted.
> 
> Craig Gallek (3):
>   sock_diag: define destruction multicast groups
>   sock_diag: specify info_size per inet protocol
>   sock_diag: implement a get_info handler for inet

Acked-by: Eric Dumazet <edumazet@google.com>
