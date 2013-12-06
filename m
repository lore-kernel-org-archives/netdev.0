From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/6] macvtap: remove the dead branch
Date: Fri, 06 Dec 2013 11:46:02 -0500 (EST)
Message-ID: <20131206.114602.2053541753179744731.davem@davemloft.net>
References: <1386282527-14094-1-git-send-email-zwu.kernel@gmail.com>
	<1386282527-14094-4-git-send-email-zwu.kernel@gmail.com>
	<52A169D4.4060209@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zwu.kernel@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, wuzhy@linux.vnet.ibm.com
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52A169D4.4060209@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Thu, 05 Dec 2013 22:08:20 -0800

> Assigning the function's return value to ret just to ignore it seems
> odd.
> 
> Might make sense to change the function type to void.

That's exactly what his very next patch does, undoubtedly the two
patches should be combined into one.
