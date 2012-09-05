From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: Commit "ipconfig wait for carrier" makes boot hang for 2 mins if no
 carrier
Date: Wed, 5 Sep 2012 23:41:06 +0200
Message-ID: <OF108CC91F.7D158BF1-ONC1257A70.00768584-C1257A70.00771E9B@transmode.se>
References: <OFFA3AC1B1.08FC3AAD-ONC1257A70.00266EDC-C1257A70.0026E8BC@transmode.se>	<50470DAC.8030009@neli.hopto.org>
	<OF70CDBF7F.EFE301C2-ONC1257A70.002F0D3F-C1257A70.003055BF@transmode.se> <20120905.130158.897788930198410991.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: micha@neli.hopto.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:55091 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759549Ab2IEVlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 17:41:08 -0400
In-Reply-To: <20120905.130158.897788930198410991.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 2012/09/05 19:01:58:
>
> From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> Date: Wed, 5 Sep 2012 10:47:56 +0200
>
> > Please adjust the 2 min wait to nfsroot= only and keep the old way for ip=
>
> Sorry, this is not happening, I fully support the change in the tree
> as-is and will not modify it in the way you request.
>
> You'll have to accomodate this situation in some other local way.

I have fixed it locally, but I would like to know why you support the current way.
It adds a incredibly long delay for systems that doesn't need a carrier, they
just want an IP address defined for a particular I/F. I cannot see why
this change would be beneficial for all.

 Jocke
