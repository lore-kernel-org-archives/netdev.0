From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6 3/4] net: diag: Support SOCK_DESTROY for inet sockets.
Date: Tue, 15 Dec 2015 09:45:20 -0800
Message-ID: <1450201520.8474.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151214.143739.879220917312503422.davem@davemloft.net>
	 <1450199868-93712-1-git-send-email-lorenzo@google.com>
	 <1450199868-93712-4-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	hannes@stressinduktion.org, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34786 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932211AbbLORpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 12:45:22 -0500
Received: by mail-pf0-f174.google.com with SMTP id o64so8289167pfb.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 09:45:22 -0800 (PST)
In-Reply-To: <1450199868-93712-4-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-16 at 02:17 +0900, Lorenzo Colitti wrote:
> This passes the SOCK_DESTROY operation to the underlying protocol
> diag handler, or returns -EOPNOTSUPP if that handler does not
> define a destroy operation.
> 
> Most of this patch is just renaming functions. This is not
> strictly necessary, but it would be fairly counterintuitive to
> have the code to destroy inet sockets be in a function whose name
> starts with inet_diag_get.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
