From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6 4/4] net: diag: Support destroying TCP sockets.
Date: Tue, 15 Dec 2015 09:46:09 -0800
Message-ID: <1450201569.8474.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151214.143739.879220917312503422.davem@davemloft.net>
	 <1450199868-93712-1-git-send-email-lorenzo@google.com>
	 <1450199868-93712-5-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	hannes@stressinduktion.org, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33034 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933632AbbLORqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 12:46:10 -0500
Received: by mail-pf0-f170.google.com with SMTP id n128so8334591pfn.0
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 09:46:10 -0800 (PST)
In-Reply-To: <1450199868-93712-5-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-16 at 02:17 +0900, Lorenzo Colitti wrote:
> This implements SOCK_DESTROY for TCP sockets. It causes all
> blocking calls on the socket to fail fast with ECONNABORTED and
> causes a protocol close of the socket. It informs the other end
> of the connection by sending a RST, i.e., initiating a TCP ABORT
> as per RFC 793. ECONNABORTED was chosen for consistency with
> FreeBSD.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Lorenzo !
