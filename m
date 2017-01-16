From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next v3 0/2] IPsec: do not ignore crypto err in ah
 input
Date: Mon, 16 Jan 2017 14:27:50 +0100
Message-ID: <20170116132750.GR3541@gauss.secunet.com>
References: <1484565476-19371-1-git-send-email-gilad@benyossef.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <ofir.drang@arm.com>,
        <gilad.benyossef@arm.com>,
        Alexander Alemayhu <alexander@alemayhu.com>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:38730 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751602AbdAPN17 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 08:27:59 -0500
Content-Disposition: inline
In-Reply-To: <1484565476-19371-1-git-send-email-gilad@benyossef.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2017 at 01:17:54PM +0200, Gilad Ben-Yossef wrote:
> ah input processing uses the asynchronous hash crypto API which
> supplies an error code as part of the operation completion but
> the error code was being ignored.
> 
> Treat a crypto API error indication as a verification failure.
> 
> While a crypto API reported error would almost certainly result
> in a memcpy of the digest failing anyway and thus the security
> risk seems minor, performing a memory compare on what might be
> uninitialized memory is wrong.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> CC: Alexander Alemayhu <alexander@alemayhu.com>

Both applied to ipsec-next, thanks a lot!
