From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: fix net_alloc_generic()
Date: Thu, 26 Jan 2012 18:07:54 -0500 (EST)
Message-ID: <20120126.180754.679593869814492219.davem@davemloft.net>
References: <4F212E7E.2040801@parallels.com>
	<1327575108.2500.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<m1zkdacbsx.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, xemul@parallels.com,
	sjur.brandeland@stericsson.com, levinsasha928@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com, sjurbren@gmail.com
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1zkdacbsx.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 26 Jan 2012 14:57:02 -0800

> It is not a chicken and egg problem.  It is a bug in caif.
> caif is claiming to be a network device when it is acting as a subsytem.
> That means it is being initialized too late.
> 
> Untested but this should trivially fix the problem, and a bunch
> of others of the same ilk.
> 
> It is not safe to shutdown subsystems until all of the devices
> are gone, otherwise there will be problems with packets in flight.

If you guys can agree that this is the better fix, and we can
get testing showing that it works, I'll revert Eric D.'s patch
and apply the final version of this one.

Thanks.
