From: Mirko Lindner <demon@pro-linux.de>
Subject: Re: [PATCH]sk98lin ethtool support
Date: Wed, 31 Dec 2003 01:37:22 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FF22852.3060101@pro-linux.de>
References: <1072779867.3632.38.camel@l5ac210.l5.laser5.co.jp> <3FF16F18.7060303@pro-linux.de> <3FF19659.8030408@pobox.com> <3FF22333.2070004@pro-linux.de> <3FF2170D.5070302@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: krishnakumar@naturesoft.net, mlindner@syskonnect.de, netdev@oss.sgi.com,
        felix@allot.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3FF2170D.5070302@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,

> Well, understood, but we don't need vendor-specific, non-standard 
> statistics when there is a standard method to export these statistics 
> (ETHTOOl_GSTATS).

I agree with you.


> Make sure you don't duplicate any ethtool functions.  We don't need a 
> NIC-specific diag tool either ;-)  ethtool is the preferred method 
> moving forward, as it's already shipping in most Linux distros.

Yes, we need it ;) No kidding! This is not a tool for SW checks like 
media, link or driver version checks, but a tool for HW checks like 
register, PROM, MAC, PHY and some other chip and card checks. The 
ethtool is a great tool, but the intention of this tool is not the same.

Mirko
