From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 09/12] net: bcmgenet: return EOPNOTSUPP for
 unknown ioctl commands
Date: Mon, 13 Mar 2017 17:57:55 -0700
Message-ID: <2023a5c6-bf5d-aacd-366b-950f01efbe8c@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
 <20170314004142.4746-10-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com
To: Doug Berger <opendmb@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-10-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/13/2017 05:41 PM, Doug Berger wrote:
> This commit changes the ioctl handling behavior to return the
> EOPNOTSUPP error code instead of the EINVAL error code when an
> unknown ioctl command value is detected.
> 
> It also removes some redundant parsing of the ioctl command value
> and allows the SIOCSHWTSTAMP value to be handled.
> 
> Signed-off-by: Doug Berger <opendmb@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
