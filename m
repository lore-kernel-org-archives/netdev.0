From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] natsemi update 1/4 Use assigned MAC address
Date: Mon, 7 Jun 2004 14:48:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607144836.1796869d@dell_ss3.pdx.osdl.net>
References: <20040608071252.77f9d69e.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, Gary.Spiess@Intermec.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
In-Reply-To: <20040608071252.77f9d69e.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 8 Jun 2004 07:12:52 +0930
Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org> wrote:

> Hi Manfred, Gary, Stephen,
> 
> "But: I'm not sure that the change is required. What about just
> setting the mac to 0, and the actual mac address is set from user
> space? It's possible to set the mac address with"

How about 
	random_ether_addr(dev->dev_addr);

it does the right thing.
