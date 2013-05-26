From: Kyle McMartin <kmcmarti@redhat.com>
Subject: Re: [PATCH] ptp_pch: depends on PCI
Date: Sun, 26 May 2013 12:20:16 -0400
Message-ID: <20130526162016.GA19205@redacted.bos.redhat.com>
References: <20130525165507.GE30204@redacted.bos.redhat.com>
 <20130525.231129.392417150870789444.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29828 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754135Ab3EZQUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 May 2013 12:20:21 -0400
Content-Disposition: inline
In-Reply-To: <20130525.231129.392417150870789444.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 25, 2013 at 11:11:29PM -0700, David Miller wrote:
> I've already told the s390 people they have to fix this properly.
> 
> They have to provide stubs for request_irq() et al. when CONFIG_PCI
> is not enabled.
> 
> This Kconfig change is therefore not appropriate.

OK. Thanks Dave.

regards, Kyle
