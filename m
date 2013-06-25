From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net-next 1/4] macvtap: Convert to using rtnl lock
Date: Tue, 25 Jun 2013 13:31:18 -0700
Message-ID: <1372192278.3301.120.camel@edumazet-glaptop>
References: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
	 <1372190662-30815-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, davem@davemloft.net
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:57230 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222Ab3FYUbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 16:31:06 -0400
Received: by mail-ee0-f44.google.com with SMTP id c13so7035546eek.3
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 13:31:05 -0700 (PDT)
In-Reply-To: <1372190662-30815-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-25 at 16:04 -0400, Vlad Yasevich wrote:
> Macvtap uses a private lock to protect the relationship between
> macvtap_queue and macvlan_dev.  The private lock is not needed
> since the relationship is managed by user via open(), release(),
> and dellink() calls.  dellink() already happens under rtnl, so
> we can safely convert open() and release(), and use it in ioctl()
> as well.
> 
> Suggested by Eric Dumazet.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/macvtap.c | 62 +++++++++++++++++++++------------------------------
>  1 file changed, 25 insertions(+), 37 deletions(-)

Looks fine to me, thanks !

Reviewed-by: Eric Dumazet <edumazet@google.com>
