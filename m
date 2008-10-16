From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] lmc: copy_*_user under spinlock
Date: Thu, 16 Oct 2008 05:12:27 -0400
Message-ID: <48F7057B.3040309@garzik.org>
References: <20081015105025.6526.68580.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36038 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754347AbYJPJMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2008 05:12:30 -0400
In-Reply-To: <20081015105025.6526.68580.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Cox wrote:
> From: Alan Cox <alan@redhat.com>
> 
> Not sure anyone uses this driver any more, maybe we should just drop it ?
> Code is still foul but at least a fraction less broken.
> 
> Signed-off-by: Alan Cox <alan@redhat.com>
> ---
> 
>  drivers/net/wan/lmc/lmc_main.c |   31 ++++++++++++++++++++++++-------
>  1 files changed, 24 insertions(+), 7 deletions(-)

applied


