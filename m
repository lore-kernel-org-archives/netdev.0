From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: NULL pointer dereference at netxen_nic_probe+0x813/0x9a0
Date: Sun, 31 Oct 2010 23:56:28 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FCEAB434C@MNEXMB2.qlogic.org>
References: <201010281250.50802.bjorn.helgaas@hp.com>
	<AANLkTim8coGDmxxCnhzXXLEswf1OYptswbA59BYcbp-N@mail.gmail.com>
	<4CCB24CA.3050106@kernel.org>
 <20101029.125403.71123384.davem@davemloft.net>,<4CCC7868.60104@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bjorn.helgaas@hp.com" <bjorn.helgaas@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Denis Kirjanov <dkirjanov@kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:53942 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab0KAE6R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 00:58:17 -0400
In-Reply-To: <4CCC7868.60104@kernel.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ok, thanks Dave, now I see.
>
> [PATCH] netxen_nic: Fix the tx queue manipulation bug in netxen_nic_probe
>
> We should not stop the egress queue during probe because it is wrong.
>
>Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
> ---
> drivers/net/netxen/netxen_nic_main.c |    1 -
> 1 files changed, 0 insertions(+), 1 deletions(-)

Thanks Denis, for fixing this.