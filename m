From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 02/10] dpaa_eth: add support for DPAA
 Ethernet
Date: Mon, 07 Nov 2016 10:55:00 -0500 (EST)
Message-ID: <20161107.105500.43380129278294700.davem@davemloft.net>
References: <1478117854-8952-3-git-send-email-madalin.bucur@nxp.com>
        <20161103.155816.642712588084106823.davem@davemloft.net>
        <AM4PR04MB16049FF6E433DA445828A855ECA70@AM4PR04MB1604.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org, oss@buserror.net,
        ppc@mindchasers.com, joe@perches.com, pebolle@tiscali.nl,
        joakim.tjernlund@transmode.se
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM4PR04MB16049FF6E433DA445828A855ECA70@AM4PR04MB1604.eurprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Date: Mon, 7 Nov 2016 15:43:26 +0000

>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Thursday, November 03, 2016 9:58 PM
>> 
>> Why?  By clearing this, you disallow an important fundamental way to do
>> performane testing, via pktgen.
> 
> The Tx path in DPAA requires one to insert a back-pointer to the skb into
> the Tx buffer. On the Tx confirmation path the back-pointer in the buffer
> is used to release the skb. If Tx buffer is shared we'd alter the back-pointer
> and leak/double free skbs. See also 

Then have your software state store an array of SKB pointers, one for each
TX ring entry, just like every other driver does.
