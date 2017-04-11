From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: stmmac: add drop transmit status feature
Date: Tue, 11 Apr 2017 17:04:58 +0200
Message-ID: <20170411150458.GK27307@lunn.ch>
References: <738665b880f7c661c4108d34a9d8fc43ef2f9fa4.1491921785.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55065 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753542AbdDKPFF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 11:05:05 -0400
Content-Disposition: inline
In-Reply-To: <738665b880f7c661c4108d34a9d8fc43ef2f9fa4.1491921785.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 11, 2017 at 03:44:10PM +0100, Joao Pinto wrote:
> When the Drop Transmit Status bit is set, the Tx packet status
> received from the MAC is dropped in the MTL. When this bit is reset,
> the Tx packet status received from the MAC is forwarded to the
> application. This feature will cause a performance improvement.

Hi Joao

Is there a reason not to turn this on by default?

   Andrew
