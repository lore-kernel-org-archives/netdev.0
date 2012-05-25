From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] gianfar:don't add FCB length to hard_header_len
Date: Fri, 25 May 2012 12:51:05 -0700
Message-ID: <1337975465.30100.4.camel@joe2Laptop>
References: <1337677248-27792-1-git-send-email-b06378@freescale.com>
	 <20120522.151830.2018953337014839778.davem@davemloft.net>
	 <4FBE4E02.1070306@computer.org> <1337876210.5070.4.camel@joe2Laptop>
	 <20120525155820.GA25102@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Ceuleers <jan.ceuleers@computer.org>,
	David Miller <davem@davemloft.net>, b06378@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:47779 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758474Ab2EYTvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 May 2012 15:51:06 -0400
In-Reply-To: <20120525155820.GA25102@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-25 at 11:58 -0400, Paul Gortmaker wrote:
> But you really shouldn't need the hardware to validate this kind of
> patch anyways -- aside from your code flow change in the irq routine of
> gianfar_ptp, you should have been simply able to check for object file
> equivalence before and after your change.

No cross compiler either, and I'm lazy 'bout that...

cheers, Joe
