From: Thomas Munck Steenholdt <tmus@tmus.dk>
Subject: Re: [PATCH] 2.6.3 orinoco.c patch to support ethtool get_link
Date: Tue, 09 Mar 2004 23:12:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404E4159.9040404@tmus.dk>
References: <20040308185242.GA18367@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>,
        hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040308185242.GA18367@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> 	I hope you realise that most often link status is meaningless
> with Wireless cards. In Ad-Hoc mode, the link is always up, regardless
> of the number of nodes in the cell, check the discussion on the HostAP
> mailing list. And the Orinoco card will report connected even is WEP
> is wrong. But, if you only use managed mode without WEP, that should
> work.
> 	I just wonder if it's better to report a 'link status' that
> may be wrong/misleading or to not report anything at all.

Actually, if the WEP key is wrong(i guess that's what you mean) the
link is determined as down, like it should be!

For the AdHoc mode, sure the link is always determined as up, but that
is really the best way to do it given the nature of an Ad-Hoc network,
right!

The way I see it you'll gain from this patch whenever in managed mode.
Most people (in my experience) is using managed mode and thus would 
benefit from this functionality!

Thomas
