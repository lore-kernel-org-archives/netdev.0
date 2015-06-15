From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] sock_diag: implement a get_info handler
 for inet
Date: Mon, 15 Jun 2015 13:30:56 -0700
Message-ID: <1434400256.27504.145.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434381980-20588-1-git-send-email-kraig@google.com>
	 <1434381980-20588-4-git-send-email-kraig@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, mleitner@redhat.com,
	stephen@networkplumber.org, davem@davemloft.net,
	ebiederm@xmission.net, tgraf@suug.ch, xemul@openvz.org
To: Craig Gallek <kraig@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34520 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbbFOUa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 16:30:59 -0400
Received: by iebmu5 with SMTP id mu5so70591700ieb.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 13:30:58 -0700 (PDT)
In-Reply-To: <1434381980-20588-4-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-15 at 11:26 -0400, Craig Gallek wrote:
> This get_info handler will simply dispatch to the appropriate
> existing inet protocol handler.
> 
> This patch also includes a new netlink attribute
> (INET_DIAG_PROTOCOL).  This attribute is currently only used
> for multicast messages.  Without this attribute, there is no
> way of knowing the IP protocol used by the socket information
> being broadcast.  This attribute is not necessary in the 'dump'
> variant of this protocol (though it could easily be added)
> because dump requests are issued for specific family/protocol
> pairs.
> 
> Tested: ss -E (note, the -E option has not yet been merged into
> the upstream version of ss).
> 
> Signed-off-by: Craig Gallek <kraig@google.com>
> ---

Note to readers : This extension was discussed during web10g talk in
Ottawa.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Craig !
