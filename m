From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net caif: Register properly as a pernet subsystem.
Date: Fri, 27 Jan 2012 21:07:13 -0500 (EST)
Message-ID: <20120127.210713.1525383740546787604.davem@davemloft.net>
References: <20120126.180754.679593869814492219.davem@davemloft.net>
	<m1ehumc8r4.fsf_-_@fess.ebiederm.org>
	<m1aa5ac8nu.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, xemul@parallels.com,
	sjur.brandeland@stericsson.com, levinsasha928@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com, sjurbren@gmail.com
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1aa5ac8nu.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 26 Jan 2012 16:04:53 -0800

> 
> caif is a subsystem and as such it needs to register with
> register_pernet_subsys instead of register_pernet_device.
> 
> Among other problems using register_pernet_device was resulting in
> net_generic being called before the caif_net structure was allocated.
> Which has been causing net_generic to fail with either BUG_ON's or by
> return NULL pointers.
> 
> A more ugly problem that could be caused is packets in flight why the
> subsystem is shutting down.
> 
> To remove confusion also remove the cruft cause by inappropriately
> trying to fix this bug.
> 
> With the aid of the previous patch I have tested this patch and
> confirmed that using register_pernet_subsys makes the failure go away as
> it should.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied.
