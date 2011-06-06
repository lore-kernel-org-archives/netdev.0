From: Rick Jones <rick.jones2@hp.com>
Subject: Re: small RPS cache for fragments?
Date: Mon, 06 Jun 2011 13:05:21 -0700
Message-ID: <1307390721.8149.2763.camel@tardy>
References: <1306273128.8149.1444.camel@tardy>
	 <20110604.132940.2214949964968775365.davem@davemloft.net>
	 <1307380132.8149.2718.camel@tardy>
	 <20110606.122217.2183968212149987796.davem@davemloft.net>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:21251 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755948Ab1FFUFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:05:23 -0400
In-Reply-To: <20110606.122217.2183968212149987796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-06 at 12:22 -0700, David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Mon, 06 Jun 2011 10:08:52 -0700
> 
> > Mode-rr bonding reorders TCP segments all the time. 
> 
> Oh well, then don't use this if you care about performance at all.
> And therefore it's not even worth considering for our RPS fragment
> cache.

Heh - the (or at least a) reason people use mode-rr is to make a single
(TCP) stream go faster :)  Without buying the next-up NIC speed.

rick jones

