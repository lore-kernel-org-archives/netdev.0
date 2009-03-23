From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] [PATCH 03/77] infiniband: convert c2 to
	net_device_ops
Date: Sun, 22 Mar 2009 21:17:04 -0700 (PDT)
Message-ID: <20090322.211704.141753947.davem@davemloft.net>
References: <20090321053527.316395697@vyatta.com>
	<20090321053712.797092692@vyatta.com> <ada4oxly1rq.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <ada4oxly1rq.fsf@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Sun, 22 Mar 2009 09:12:57 -0700

> Don't I already have this queued in my for-next branch?
> 
> Or is this an updated version?
> 
> [And same applies to the nes driver changes]

Any chance you can drop the copies in your tree?

The reason I'm asking is that once all the conversions are in
net-next-2.6 which hit the i386 allmodconfig build there is a change
we can add (which in fast is in net-next-2.6 now) which exposes a
config option to turn all of the pre-netdev_ops compatibility stuff
off.

We can't do that until i386 builds in all configurations.
