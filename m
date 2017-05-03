From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] xdp: use common helper for netlink extended ack
 reporting
Date: Wed, 03 May 2017 07:32:18 +0200
Message-ID: <1493789538.2602.1.camel@sipsolutions.net>
References: <9dc20d2c3cca095b42e730655c8fd9f5d59a4568.1493763990.git.daniel@iogearbox.net>
         (sfid-20170503_003943_207006_970DAEB4)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:60648 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751010AbdECFc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 01:32:28 -0400
In-Reply-To: <9dc20d2c3cca095b42e730655c8fd9f5d59a4568.1493763990.git.daniel@iogearbox.net> (sfid-20170503_003943_207006_970DAEB4)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-05-03 at 00:39 +0200, Daniel Borkmann wrote:
> Small follow-up to d74a32acd59a ("xdp: use netlink extended ACK
> reporting")
> in order to let drivers all use the same NL_SET_ERR_MSG_MOD() helper
> macro
> for reporting. This also ensures that we consistently add the
> driver's
> prefix for dumping the report in user space to indicate that the
> error
> message is driver specific and not coming from core code.
> Furthermore,
> NL_SET_ERR_MSG_MOD() now reuses NL_SET_ERR_MSG() and thus makes all
> macros
> check the pointer as suggested.
> 
> References: https://www.spinics.net/lists/netdev/msg433267.html
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

I did wonder about the whole _TRY_ thing. LGTM

Reviewed-by: Johannes Berg <johannes@sipsolutions.net>

johannes
