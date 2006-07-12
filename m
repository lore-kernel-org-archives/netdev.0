From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [ROSE] lockdep: fix false positive
Date: Wed, 12 Jul 2006 11:42:23 +0200
Message-ID: <20060712094223.GB9528@elte.hu>
References: <20060711221357.GA5813@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:40370 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S1751203AbWGLJrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 05:47:47 -0400
To: Ralf Baechle <ralf@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20060711221357.GA5813@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ralf Baechle <ralf@linux-mips.org> wrote:

> ROSE network devices are virtual network devices encapsulating ROSE
> frames into AX.25 which will be sent through an AX.25 device, so form a
> special "super class" of normal net devices; split their locks off into
> a separate class since they always nest.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

thanks,

Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo
