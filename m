From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bonding: Manage /proc/net/bonding/ entries from
 the netdev events
Date: Mon, 09 Jul 2012 14:49:26 -0700 (PDT)
Message-ID: <20120709.144926.373399647799528683.davem@davemloft.net>
References: <87fw94g1kq.fsf@xmission.com>
	<20120706194741.GA22113@mail.hallyn.com>
	<87y5ms3bfi.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dilip.daya@hp.com, linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	serge@hallyn.com
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y5ms3bfi.fsf_-_@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 09 Jul 2012 13:51:45 -0700

> 
> It was recently reported that moving a bonding device between network
> namespaces causes warnings from /proc.  It turns out after the move we
> were trying to add and to remove the /proc/net/bonding entries from the
> wrong network namespace.
> 
> Move the bonding /proc registration code into the NETDEV_REGISTER and
> NETDEV_UNREGISTER events where the proc registration and unregistration
> will always happen at the right time.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied.
