From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next] team: init error value to 0 in
 team_netpoll_setup()
Date: Tue, 24 Jul 2012 13:39:33 +0200
Message-ID: <1343129973.2626.11061.camel@edumazet-glaptop>
References: <1343128848-1284-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33727 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305Ab2GXLjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 07:39:40 -0400
Received: by bkwj10 with SMTP id j10so6208065bkw.19
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 04:39:37 -0700 (PDT)
In-Reply-To: <1343128848-1284-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-24 at 13:20 +0200, Jiri Pirko wrote:
> This will ensure correct value is returned in case the port list is empty.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  drivers/net/team/team.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Reported-by: Eric Dumazet <edumazet@google.com>
