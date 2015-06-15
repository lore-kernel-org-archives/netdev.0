From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] sock_diag: specify info_size per inet
 protocol
Date: Mon, 15 Jun 2015 13:29:26 -0700
Message-ID: <1434400166.27504.143.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434381980-20588-1-git-send-email-kraig@google.com>
	 <1434381980-20588-3-git-send-email-kraig@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, mleitner@redhat.com,
	stephen@networkplumber.org, davem@davemloft.net,
	ebiederm@xmission.net, tgraf@suug.ch, xemul@openvz.org
To: Craig Gallek <kraig@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:38503 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384AbbFOU32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 16:29:28 -0400
Received: by igblz2 with SMTP id lz2so59297756igb.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 13:29:27 -0700 (PDT)
In-Reply-To: <1434381980-20588-3-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-15 at 11:26 -0400, Craig Gallek wrote:
> Previously, there was no clear distinction between the inet protocols
> that used struct tcp_info to report information and those that didn't.
> This change adds a specific size attribute to the inet_diag_handler
> struct which defines these interfaces.  This will make dispatching
> sock_diag get_info requests identical for all inet protocols in a
> following patch.
> 
> Tested: ss -au
> Tested: ss -at
> Signed-off-by: Craig Gallek <kraig@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
