From: Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 05/36] block,rcu: convert call_rcu(disk_free_ptbl_rcu_cb)
  to kfree_rcu()
Date: Fri, 18 Mar 2011 07:59:53 +0100
Message-ID: <4D8302E9.30303@kernel.dk>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com> <4D82D4C2.8020503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <James.Bottomley@suse.de>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Tejun Heo <tj@kernel.org>, Jarek Poplawski <jarkao2@gmail.com>,
	linux-kernel@vger.kernel.org, devel@open-fcoe.org,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <4D82D4C2.8020503@cn.fujitsu.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2011-03-18 04:42, Lai Jiangshan wrote:
> 
> 
> The rcu callback disk_free_ptbl_rcu_cb() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(disk_free_ptbl_rcu_cb).

Thanks, I'll add this.

-- 
Jens Axboe

