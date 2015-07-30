From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: Switch tag HW extraction/insertion
Date: Thu, 30 Jul 2015 14:19:35 -0700 (PDT)
Message-ID: <20150730.141935.723435302404122784.davem@davemloft.net>
References: <1438209160-6898-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438209160-6898-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 29 Jul 2015 15:32:37 -0700

> This patch series adds two new feature flags to allow Ethernet controllers
> capable of doing Ethernet switch proprietary tag insertion/extraction to
> benefit from that.
> 
> The last two patches modify the Broadcom tag parsing code in DSA to utilize
> that feature and finally, the SYSTEMPORT controller driver is updated to
> turn on that feature when requested.
> 
> The ethtool patch will follow-up shortly as well.
> 
> Insertion on transmit is still work in progress and requires more turning on
> how the SYSTEMPORT transmit queues are mapped to their respective switch ports
> and queues (there are 32 queues on SYSTEMPORT to output to a 4-port switch each
> port with 8 transmit queues).

This looks fine, series applied, thanks.
