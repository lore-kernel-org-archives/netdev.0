From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 06/10] net/ncsi: Ethtool operation to get
 NCSI hw statistics
Date: Wed, 03 May 2017 09:18:23 -0400 (EDT)
Message-ID: <20170503.091823.747316360571887178.davem@davemloft.net>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
        <1493786681-27468-7-git-send-email-gwshan@linux.vnet.ibm.com>
        <20170503124722.GE8029@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gwshan@linux.vnet.ibm.com, netdev@vger.kernel.org, joe@perches.com,
        kubakici@wp.pl, f.fainelli@gmail.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36608 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751354AbdECNS2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 09:18:28 -0400
In-Reply-To: <20170503124722.GE8029@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 3 May 2017 14:47:22 +0200

> On Wed, May 03, 2017 at 02:44:37PM +1000, Gavin Shan wrote:
>> This adds ethtool command (ETHTOOL_GNCSISTATS) to retrieve the
>> NCSI hardware statistics.
> 
> Hi Gavin
> 
> I've not been following this patchset, so maybe i'm about to ask a
> question which has already been asked and answered.
> 
> Why cannot use just use ethtool -S for this?

Indeed, when I said to use ethtool for these NCSI hw stats I meant
that the "ethtool -S" be used, not some new ethtool command.
