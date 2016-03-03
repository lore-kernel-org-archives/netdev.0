From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] net/ethoc: do not free array priv->mdio->irq
Date: Thu, 3 Mar 2016 15:12:57 +0100
Message-ID: <20160303141257.GA428@distanz.ch>
References: <1457012614-19564-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Fabian Frederick <fabf@skynet.be>,
	Max Filippov <jcmvbkbc@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:54488 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757835AbcCCOTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 09:19:22 -0500
Content-Disposition: inline
In-Reply-To: <1457012614-19564-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-03-03 at 14:43:34 +0100, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> priv->mdio->irq used to be allocated and required freeing, but it
> is now a fixed sized array and should no longer be free'd.
> 
> Issue detected using static analysis with CoverityScan
> 
> Fixes: e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>
