From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [REGRESSION, PATCH] sky2 WOL fix
Date: Fri, 17 Feb 2012 11:01:47 -0800
Message-ID: <20120217110147.1c00b31d@nehalam.linuxnetplumber.net>
References: <4F3A1A5E.9090803@t-online.de>
	<20120215091622.429fe9c3@nehalam.linuxnetplumber.net>
	<4F3E9AC1.6060704@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dilieto@lineone.net,
	Mirko Lindner <mlindner@syskonnect.de>,
	Ralph Roesler <rroesler@syskonnect.de>, arekm@maven.pl,
	nitro@legroom.net, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
To: Knut Petersen <Knut_Petersen@t-online.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44066 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061Ab2BQTBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Feb 2012 14:01:50 -0500
In-Reply-To: <4F3E9AC1.6060704@t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Feb 2012 19:21:53 +0100
Knut Petersen <Knut_Petersen@t-online.de> wrote:

> Your commit broke existing support for WOL on a number of boards.
> This is known to you and to bugzilla.kernel org since 2010.  A number of
> people complained about that, but nothing happened.
> 
> Neither your original commit description nor the description of the
> PXE_LegNat_Sel I found at other places indicate that setting
> PXE_LegNat_Sel could do any harm.


Please lose the attitude. Any support of sky2 is done as a minor side
project by me. People find a problem, I put in one fix, then someone else
complains and another fix goes in. The regressions happen a lot in power management
because the hardware is not well documented in this area and it is a complex
interaction of kernel, BIOS, motherboard, and general shittiness of implementations.
Because of that I am more likely to believe that what the Marvell code does
is more based on experience on other platforms. The out-of-tree Marvell
driver contains bits that are part of the Windows driver.
