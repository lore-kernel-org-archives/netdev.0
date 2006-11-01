From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: netpoll on dual port cards
Date: Tue, 31 Oct 2006 20:19:19 -0500
Message-ID: <4547F617.6050106@pobox.com>
References: <20061018133928.60052617@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:22483 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1423911AbWKABTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 20:19:23 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061018133928.60052617@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The sky2 driver uses a single NAPI poll routine for both ports on dual ported
> cards (because there is a single IRQ and status ring). Netpoll makes assumptions
> about the relationship between network device and NAPI that aren't correct
> on the second port, this will cause the port to never clear work.
> 
> Most systems, just have single port, so not a big issue.
> The easy fix is just make the second port, not netpoll capable.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

applied to #upstream-fixes


