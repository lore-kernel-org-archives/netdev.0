From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH 3/3] net-next: mediatek: add RX delay support
Date: Thu, 5 May 2016 19:37:35 +0200
Message-ID: <d35c9a8c-0988-094f-a12c-6d91f95b1b46@phrozen.org>
References: <1462439856-51788-1-git-send-email-john@phrozen.org>
 <1462439856-51788-4-git-send-email-john@phrozen.org>
 <20160505121353.GE7972@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, nbd@nbd.name
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160505121353.GE7972@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05/05/2016 14:13, Andrew Lunn wrote:
> On Thu, May 05, 2016 at 11:17:36AM +0200, John Crispin wrote:
>> If an external Gigabit PHY is connected to either of the MACs we need to
>> tell the to use a RX delay. Not doing so will result in heavy packet loss
>> and/or data corruption of RX traffic.
> 
> Hi John
> 
> Is this comment correct? Reading the code, all this switch statement
> does is select between RGMII, MII and RMII. It has nothing to do with
> delay. I suspect the PHY is doing the delay, not the MAC, since you
> pass the phy mode to of_phy_connect().
> 
> If my interpretation of the code is correct, you might also want to
> handle PHY_INTERFACE_MODE_RGMII_TXID and PHY_INTERFACE_MODE_RGMII_ID
> which are also RGMII modes.
> 
>       Andrew

Hi Andrew,

the comment is indeed incorrect and the PHY needs to handle the delay. i
will send a V2 and also add _TXID and _ID

	John
