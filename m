From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] sunvnet: implement basic ethtool
 get_settings
Date: Wed, 21 Jun 2017 15:06:34 -0400 (EDT)
Message-ID: <20170621.150634.1121246733116528491.davem@davemloft.net>
References: <1498061394-233018-1-git-send-email-shannon.nelson@oracle.com>
        <1498061394-233018-3-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: shannon.nelson@oracle.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1498061394-233018-3-git-send-email-shannon.nelson@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Wed, 21 Jun 2017 09:09:54 -0700

> Add the get_settings callback so that both the ldmvsw and sunvnet
> drivers will give a little more information when asked for its
> basic settings.  These aren't necessarily very useful, but they
> make some users happier.  Also, a side effect is that the speed
> attribute in /sys/class/net/<dev> is now readable, which makes
> a couple of the ldom management tools happier.
> 
> Orabug: 26175474
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>

I would set the speed to something other than zero, and also
consider the ramifications of this change upon things like
'bonding' and 'team'.
