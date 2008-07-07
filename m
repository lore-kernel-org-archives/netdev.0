From: David Miller <davem@davemloft.net>
Subject: Re: Wrong padding of short packets send by a tagged-vlan interface?
Date: Mon, 07 Jul 2008 14:54:31 -0700 (PDT)
Message-ID: <20080707.145431.149346529.davem@davemloft.net>
References: <Pine.LNX.4.64.0807072210470.15459@bizon.gios.gov.pl>
	<4872854C.201@trash.net>
	<Pine.LNX.4.64.0807072337320.15459@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, greearb@candelatech.com
To: olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53558
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756077AbYGGVyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 17:54:31 -0400
In-Reply-To: <Pine.LNX.4.64.0807072337320.15459@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Oledzki <olel@ans.pl>
Date: Mon, 7 Jul 2008 23:40:58 +0200 (CEST)

> Not all drivers use skb_padto:
> 
> # grep skb_padto -R e1000 e1000e bnx*.c
> (empty)
> 
> Any idea where to change it in the above ones?

They don't need to, most devices handle this issue
in hardware as far as I understand.
