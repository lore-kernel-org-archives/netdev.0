From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 9/9] SCTP: Follow Add-IP security consideratiosn
 wrt INIT/INIT-ACK
Date: Thu, 20 Dec 2007 14:13:39 -0800 (PST)
Message-ID: <20071220.141339.196266068.davem@davemloft.net>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
	<1197927169-5106-10-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39695
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754957AbXLTWNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 17:13:40 -0500
In-Reply-To: <1197927169-5106-10-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 17 Dec 2007 16:32:49 -0500

> The Security Considerations section of RFC 5061 has the following
> text:
> 
>    If an SCTP endpoint that supports this extension receives an INIT
>    that indicates that the peer supports the ASCONF extension but does
>    NOT support the [RFC4895] extension, the receiver of such an INIT
>    MUST send an ABORT in response.  Note that an implementation is
>    allowed to silently discard such an INIT as an option as well, but
>    under NO circumstance is an implementation allowed to proceed with
>    the association setup by sending an INIT-ACK in response.
> 
>    An implementation that receives an INIT-ACK that indicates that the
>    peer does not support the [RFC4895] extension MUST NOT send the
>    COOKIE-ECHO to establish the association.  Instead, the
>    implementation MUST discard the INIT-ACK and report to the upper-
>    layer user that an association cannot be established destroying the
>    Transmission Control Block (TCB).
> 
> Follow the recomendations.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks.
