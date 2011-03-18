From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 20/36] net,rcu: convert call_rcu(netlbl_unlhsh_free_addr4) to kfree_rcu()
Date: Fri, 18 Mar 2011 16:05:48 -0400
Message-ID: <201103181605.48331.paul.moore@hp.com>
References: <4D82D9AC.30205@cn.fujitsu.com> <20110318.123651.245394297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: laijs@cn.fujitsu.com, paulmck@linux.vnet.ibm.com, mingo@elte.hu,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110318.123651.245394297.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, March 18, 2011 3:36:51 PM David Miller wrote:
> From: Lai Jiangshan <laijs@cn.fujitsu.com>
> Date: Fri, 18 Mar 2011 12:03:56 +0800
> 
> > The rcu callback netlbl_unlhsh_free_addr4() just calls a kfree(),
> > so we use kfree_rcu() instead of the call_rcu(netlbl_unlhsh_free_addr4).
> > 
> > Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Me too ...

Acked-by: Paul Moore <paul.moore@hp.com>

--
paul moore
linux @ hp
