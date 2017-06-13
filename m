From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] of_mdio: move of_mdio_parse_addr to header file
Date: Tue, 13 Jun 2017 09:49:01 -0700
Message-ID: <23f97bac-8fdd-77e5-364d-0ea3a395d0c6@gmail.com>
References: <1497365768-17627-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>,
        Michael Ellerman <mpe@ellerman.id.au>
To: Jon Mason <jon.mason@broadcom.com>, Andrew Lunn <andrew@lunn.ch>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497365768-17627-1-git-send-email-jon.mason@broadcom.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/13/2017 07:56 AM, Jon Mason wrote:
> The of_mdio_parse_addr() helper function is useful to other code, but
> the module dependency chain causes issues.  To work around this, we can
> move of_mdio_parse_addr() to be an inline function in the header file.
> This gets rid of the dependencies and still allows for the reuse of
> code.
> 
> Reported-by: Liviu Dudau <liviu@dudau.co.uk>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> Fixes: 342fa1964439 ("mdio: mux: make child bus walking more permissive and errors more verbose")

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
-- 
Florian
