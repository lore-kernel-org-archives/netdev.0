From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sunvnet: don't change gso data on clones
Date: Wed, 11 Feb 2015 19:06:50 -0800
Message-ID: <1423710410.4942.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54DB5711.3040705@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:57080 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753447AbbBLDGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 22:06:52 -0500
Received: by mail-qc0-f178.google.com with SMTP id p6so6406430qcv.9
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 19:06:52 -0800 (PST)
In-Reply-To: <54DB5711.3040705@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-11 at 08:20 -0500, David L Stevens wrote:
> This patch unclones an skb for the case where the sunvnet driver needs to
> change the segmentation size so that it doesn't interfere with TCP SACK's
> use of them.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
