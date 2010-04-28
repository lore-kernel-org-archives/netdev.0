From: Cong Wang <amwang@redhat.com>
Subject: Re: [v4 Patch 3/3] bonding: make bonding support netpoll
Date: Wed, 28 Apr 2010 10:08:57 +0800
Message-ID: <4BD798B9.3010007@redhat.com>
References: <20100427075937.4908.18468.sendpatchset@localhost.localdomain>	<20100427080004.4908.27339.sendpatchset@localhost.localdomain> <20100427.152424.236240666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mpm@selenic.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	gospo@redhat.com, nhorman@tuxdriver.com, jmoyer@redhat.com,
	shemminger@linux-foundation.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100427.152424.236240666.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Amerigo Wang <amwang@redhat.com>
> Date: Tue, 27 Apr 2010 03:56:09 -0400
> 
>> +		if ((slave->dev->priv_flags & IFF_DISABLE_NETPOLL)
>> +				|| !slave->dev->netdev_ops->ndo_poll_controller)
> 
> "|| on first line please, plus fix second line's indentation as per
> comments given in patch #1 and #2

Thanks, David!
I will fix all of this style problem.
