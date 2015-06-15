From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] sock_diag: define destruction multicast
 groups
Date: Mon, 15 Jun 2015 13:29:11 -0700
Message-ID: <1434400151.27504.142.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434381980-20588-1-git-send-email-kraig@google.com>
	 <1434381980-20588-2-git-send-email-kraig@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, mleitner@redhat.com,
	stephen@networkplumber.org, davem@davemloft.net,
	ebiederm@xmission.net, tgraf@suug.ch, xemul@openvz.org
To: Craig Gallek <kraig@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:32863 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755876AbbFOU3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 16:29:13 -0400
Received: by igbos3 with SMTP id os3so28400447igb.0
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 13:29:13 -0700 (PDT)
In-Reply-To: <1434381980-20588-2-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-15 at 11:26 -0400, Craig Gallek wrote:
> These groups will contain socket-destruction events for
> AF_INET/AF_INET6, IPPROTO_TCP/IPPROTO_UDP.
> 
> Near the end of socket destruction, a check for listeners is
> performed.  In the presence of a listener, rather than completely
> cleanup the socket, a unit of work will be added to a private
> work queue which will first broadcast information about the socket
> and then finish the cleanup operation.
> 
> Signed-off-by: Craig Gallek <kraig@google.com>

Acked-by: Eric Dumazet <edumazet@google.com>
