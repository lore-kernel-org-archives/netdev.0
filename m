From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] tcp: reduce cpu usage when SO_SNDBUF is
 set
Date: Wed, 22 Jun 2016 11:43:41 -0700
Message-ID: <1466621021.6850.71.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1466608332.git.jbaron@akamai.com>
	 <c873de17bfcf341eafda5ee7762c3f2c26579ff1.1466608332.git.jbaron@akamai.com>
	 <1466616854.6850.69.camel@edumazet-glaptop3.roam.corp.google.com>
	 <576AD666.7050809@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34602 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbcFVSno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 14:43:44 -0400
Received: by mail-pa0-f53.google.com with SMTP id bz2so19217353pad.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 11:43:43 -0700 (PDT)
In-Reply-To: <576AD666.7050809@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-22 at 14:18 -0400, Jason Baron wrote:
> 

> 
> For 1/2, the getting the correct memory barrier, should I re-submit
> that as a separate patch?

Are you sure a full memory barrier (smp_mb() is needed ?

Maybe smp_wmb() would be enough ?

(And smp_rmb() in tcp_poll() ?)
