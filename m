From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] net: emac: emac gigabit ethernet controller driver
Date: Tue, 15 Dec 2015 15:09:23 -0600
Message-ID: <56708183.4090005@codeaurora.org>
References: <1450138740-32562-1-git-send-email-gavidov@codeaurora.org>
 <1594472.ixZvj6PYdz@wuerfel> <56702EEC.8000506@codeaurora.org>
 <1579270.z2ZaCA4LQo@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christopher Covington <cov@codeaurora.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Gilad Avidov <gavidov@codeaurora.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, gregkh@linuxfoundation.org,
	vikrams@codeaurora.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1579270.z2ZaCA4LQo@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> If that's in the probe() called from it function, just use writel() everywhere,
> a few extra microseconds won't kill the boot time. In general, if a user would
> notice the difference, use the relaxed version and add a comment to explain
> how you proved it's correct, otherwise stay with the default accessors.

What about adding a wmb() after the last writel()?  This driver does 
that a lot.  Is that something we want to discourage?  I can understand 
how we would want to make sure that the last write is posted before the 
function exits.
