From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/3] net/phy: micrel: Center FLP timing at 16ms
Date: Mon, 08 Jun 2015 00:51:30 -0700 (PDT)
Message-ID: <20150608.005130.742724237263501733.davem@davemloft.net>
References: <1433545226-18324-1-git-send-email-jaeden.amero@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jaeden.amero@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433545226-18324-1-git-send-email-jaeden.amero@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jaeden Amero <jaeden.amero@ni.com>
Date: Fri, 5 Jun 2015 18:00:23 -0500

> In v2, we add an additional cleanup commit to make an array of strings
> static const and to improve const correctness generally. We also no longer
> unnecessarily initialize the result variable in
> ksz9031_center_flp_timing().
> 
> In v3, we remove the unnecessary result variable from ksz9031_config_init()
> introduced by a previous version of "net/phy: micrel: Center FLP timing at
> 16ms".
> 
> In v4, we modify the commit message of "net/phy: micrel: Center FLP timing
> at 16ms" to replace the awkward quotation of the data sheet's programming
> procedure with an explanation of why we program the FLP burst registers and
> restart auto-negotiation where we do (config_init).

Series applied to net-next, thanks.
