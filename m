From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] of_mdio: move of_mdio_parse_addr to header
 file
Date: Tue, 13 Jun 2017 14:00:34 -0400 (EDT)
Message-ID: <20170613.140034.1178710287073869026.davem@davemloft.net>
References: <1497365768-17627-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, robh+dt@kernel.org,
        frowand.list@gmail.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        liviu@dudau.co.uk, mpe@ellerman.id.au
To: jon.mason@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497365768-17627-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Mason <jon.mason@broadcom.com>
Date: Tue, 13 Jun 2017 10:56:08 -0400

> The of_mdio_parse_addr() helper function is useful to other code, but
> the module dependency chain causes issues.  To work around this, we can
> move of_mdio_parse_addr() to be an inline function in the header file.
> This gets rid of the dependencies and still allows for the reuse of
> code.
> 
> Reported-by: Liviu Dudau <liviu@dudau.co.uk>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> Fixes: 342fa1964439 ("mdio: mux: make child bus walking more permissive and errors more verbose")

Applied, thank you.
