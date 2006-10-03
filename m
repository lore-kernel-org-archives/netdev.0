From: Martin Lucina <mato@kotelna.sk>
Subject: Re: sky2 hangs, hw csum errors with 2.6.18
Date: Tue, 3 Oct 2006 21:23:59 +0200
Message-ID: <20061003192358.GS14180@dezo.moloch.sk>
References: <20060922182924.GE4161@dezo.moloch.sk> <20060922113152.02874cbc@localhost.localdomain> <20060922183812.GF4161@dezo.moloch.sk> <20060922115008.5060c599@localhost.localdomain> <20061003182119.GM14180@dezo.moloch.sk> <20061003113538.4c3fe57d@freekitty> <20061003183948.GO14180@dezo.moloch.sk> <20061003120355.0730097a@freekitty> <20061003191350.GP14180@dezo.moloch.sk> <20061003121624.77a08cb5@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:24761 "EHLO mail.moloch.sk")
	by vger.kernel.org with ESMTP id S1030488AbWJCTYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 15:24:02 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061003121624.77a08cb5@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

shemminger@osdl.org said:
> If you are seeing truesize errors with the stock 2.6.18 kernel then
> some other protocol is messing with the skb's?  Are you using IPV6?
> Or PPPoE or something like that.

Only thing like that that is running here is OpenVPN which is using a
tun interface.  There's hardly any traffic running over that though.
Could that explain  the truesize errors?

Doesn't explain the sky2 tx timeouts though...

-mato
