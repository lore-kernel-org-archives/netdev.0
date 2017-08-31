From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC net-next 1/8] net: dsa: Allow switch drivers to indicate
 number of RX/TX queues
Date: Fri, 1 Sep 2017 01:44:12 +0200
Message-ID: <20170831234412.GA28960@lunn.ch>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
 <1504138732-65383-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@resnulli.us, jhs@mojatatu.com,
        davem@davemloft.net, xiyou.wangcong@gmail.com,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47595 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751404AbdHaXoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 19:44:16 -0400
Content-Disposition: inline
In-Reply-To: <1504138732-65383-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 30, 2017 at 05:18:45PM -0700, Florian Fainelli wrote:
> Let switch drivers indicate how many RX and TX queues they support. Some
> switches, such as Broadcom Starfighter 2 are resigned with 8 egress
> queues.

Marvell switches also have egress queue.

Does the SF2 have ingress queues? Marvel don't as far as i known.  So
i wounder if num_rx_queues is useful?

Do switches in general have ingress queues? 

   Andrew
