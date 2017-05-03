From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 net-next 08/10] net/ncsi: Support NCSI packet
 generation
Date: Wed, 3 May 2017 14:52:54 +0200
Message-ID: <20170503125254.GF8029@lunn.ch>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-9-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, joe@perches.com, kubakici@wp.pl,
        f.fainelli@gmail.com, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49022 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751108AbdECMw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 08:52:56 -0400
Content-Disposition: inline
In-Reply-To: <1493786681-27468-9-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 03, 2017 at 02:44:39PM +1000, Gavin Shan wrote:
> This introduces /sys/kernel/debug/ncsi/eth0/pkt. The debugfs entry
> can accept parameters to produce NCSI command packet. The received
> NCSI response packet is dumped on read. Below is an example to send
> CIS command and dump its response.
> 
>    # echo CIS,0,0 > /sys/kernel/debug/ncsi/eth0/pkt
>    # cat /sys/kernel/debug/ncsi/eth0/pkt
>    NCSI response [CIS] packet received
> 
>    00 01 dd 80 00 0004 0000 0000

Hi Gavin

Could this be done with a raw socket for Tx and
libpcap/tcpdump/wireshart for Rx?

      Andrew
