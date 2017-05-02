From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH] xdp: use common helper for netlink extended ack
 reporting
Date: Tue, 2 May 2017 15:52:11 -0700
Message-ID: <20170502155211.770dde0b@cakuba.netronome.com>
References: <9dc20d2c3cca095b42e730655c8fd9f5d59a4568.1493763990.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33275 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdEBWwO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 18:52:14 -0400
Received: by mail-pf0-f176.google.com with SMTP id q20so3795397pfg.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 15:52:14 -0700 (PDT)
In-Reply-To: <9dc20d2c3cca095b42e730655c8fd9f5d59a4568.1493763990.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  3 May 2017 00:39:17 +0200, Daniel Borkmann wrote:
> Small follow-up to d74a32acd59a ("xdp: use netlink extended ACK reporting")
> in order to let drivers all use the same NL_SET_ERR_MSG_MOD() helper macro
> for reporting. This also ensures that we consistently add the driver's
> prefix for dumping the report in user space to indicate that the error
> message is driver specific and not coming from core code. Furthermore,
> NL_SET_ERR_MSG_MOD() now reuses NL_SET_ERR_MSG() and thus makes all macros
> check the pointer as suggested.
> 
> References: https://www.spinics.net/lists/netdev/msg433267.html
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Perhaps I was overthinking loosing the message if extack is NULL.  
I certainly like how this patch simplifies things :)
