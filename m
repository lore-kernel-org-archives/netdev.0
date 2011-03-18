From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH 05/36] block,rcu: convert
	call_rcu(disk_free_ptbl_rcu_cb) to kfree_rcu()
Date: Fri, 18 Mar 2011 05:20:50 -0600
Message-ID: <20110318112049.GA13806@parisc-linux.org>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com> <4D82D4C2.8020503@cn.fujitsu.com> <4D8302E9.30303@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
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
To: Jens Axboe <axboe@kernel.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:42994 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110Ab1CRLUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 07:20:54 -0400
Content-Disposition: inline
In-Reply-To: <4D8302E9.30303@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2011 at 07:59:53AM +0100, Jens Axboe wrote:
> On 2011-03-18 04:42, Lai Jiangshan wrote:
> > 
> > 
> > The rcu callback disk_free_ptbl_rcu_cb() just calls a kfree(),
> > so we use kfree_rcu() instead of the call_rcu(disk_free_ptbl_rcu_cb).
> 
> Thanks, I'll add this.

Don't be in too much of a hurry ... kfree_rcu() doesn't appear to have
hit Linus' tree yet.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
