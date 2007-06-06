From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 19:54:47 -0400
Message-ID: <1181174087.4064.100.camel@localhost>
References: <1181082517.4062.31.camel@localhost>
	 <4666CEB7.6030804@trash.net> <1181168020.4064.46.camel@localhost>
	 <20070606.153530.48530367.davem@davemloft.net>
	 <1181172766.4064.83.camel@localhost>  <466747EB.5020101@hp.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:50860 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755841AbXFFXyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 19:54:51 -0400
Received: by py-out-1112.google.com with SMTP id a29so568230pyi
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2007 16:54:50 -0700 (PDT)
In-Reply-To: <466747EB.5020101@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-06-06 at 16:48 -0700, Rick Jones wrote:
>   > RX queues - yes, I can see;  TX queues, it doesnt make sense to put
> > different rings on different CPUs.
> 
> To what extent might that preclude some cachelines bouncing hither and 
> yon between the CPUs?

I think the bouncing will exist a lot more with the multi CPUs. But one
would assume if you go that path, you would also parallelize the stack
on egress to reduce such an effect. I guess the point i am not seeing is
the value. The tx, once hitting the NIC is an IO issue not a CPU issue.
OTOH, the receive path once a packet is received, that is a CPU problem
(and therefore multi CPUs help).

To be fair to Peter, that is not what his patches are trying to address
(and infact, they cant solve that problem).

off for the night.

cheers,
jamal

