From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: turn carrier off on phy attach
Date: Tue, 12 Jan 2016 17:31:04 -0800
Message-ID: <10DF45FB-A812-4D6F-8B45-817B86FD48CE@gmail.com>
References: <1452365045-5364-1-git-send-email-sjoerd.simons@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452365045-5364-1-git-send-email-sjoerd.simons@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On January 9, 2016 10:44:05 AM PST, Sjoerd Simons <sjoerd.simons@collabora.co.uk> wrote:
>The operstate of a networking device initially IF_OPER_UNKNOWN aka
>"unknown", updated on carrier state changes (with carrier state being
>on
>by default). This means it will stay unknown unless the carrier state
>goes to off at some point, which is not the case if the phy is already
>up/connected at startup.

Correct, drivers typically call netif_carrier_off prior to registering the network device to give a predictable link state, regardless of whether or not they use PHYLIB.

>
>Explicitly turn off the carrier on phy attach, leaving the phy state
>machine to turn the carrier on when it has done the initial
>negotiation.

Same comment as Andrew on the comment below.

Out of curiosity, was there a particular driver you ran into issues with?

-- 
Florian
