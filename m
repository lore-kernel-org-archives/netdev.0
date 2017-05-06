From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: loop: Check for memory allocation failure
Date: Sat, 6 May 2017 16:45:19 +0200
Message-ID: <20170506144519.GA23180@lunn.ch>
References: <20170506052945.2639-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52017 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750947AbdEFOpX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 6 May 2017 10:45:23 -0400
Content-Disposition: inline
In-Reply-To: <20170506052945.2639-1-christophe.jaillet@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 06, 2017 at 07:29:45AM +0200, Christophe JAILLET wrote:
> If 'devm_kzalloc' fails, a NULL pointer will be dereferenced.
> Return -ENOMEM instead, as done for some other memory allocation just a
> few lines above.
> 
> Fixes: 98cd1552ea27 ("net: dsa: Mock-up driver")
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
