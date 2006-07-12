From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH]NET: Add ECN support for TSO
Date: Wed, 12 Jul 2006 10:15:36 -0700
Message-ID: <000501c6a5d6$cac1a2f0$4710100a@pc.s2io.com>
References: <20060711.231149.77849003.davem@davemloft.net>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:7138 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S932095AbWGLRQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 13:16:12 -0400
To: "'David Miller'" <davem@davemloft.net>, <mchan@broadcom.com>
In-Reply-To: <20060711.231149.77849003.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks.. I will get rid of the per-session check for ECN.

Ravi

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: Tuesday, July 11, 2006 11:12 PM
To: mchan@broadcom.com
Cc: ravinandan.arakali@neterion.com; herbert@gondor.apana.org.au;
netdev@vger.kernel.org
Subject: Re: [PATCH]NET: Add ECN support for TSO


From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 11 Jul 2006 21:53:42 -0700

> There is no reason to find out if ECN is enabled or not for any
> TCP connections.  Hw just needs to watch the above bits in the
> incoming packets.

Correct, it can be done in a completely stateless manner.
