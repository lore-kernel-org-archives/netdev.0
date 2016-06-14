From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 1/3] macsec: add rcu_barrier() on module exit
Date: Tue, 14 Jun 2016 16:18:26 +0200
Message-ID: <64e11819-5eda-2479-5a89-06f967c20a3c@stressinduktion.org>
References: <cover.1465908271.git.sd@queasysnail.net>
 <5120805ba38a47a8f5c662191339fc4f9e50f44a.1465908271.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:42758 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752715AbcFNOSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 10:18:32 -0400
In-Reply-To: <5120805ba38a47a8f5c662191339fc4f9e50f44a.1465908271.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.06.2016 15:25, Sabrina Dubroca wrote:
> Without this, the various uses of call_rcu could cause a kernel panic.
> 
> Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
