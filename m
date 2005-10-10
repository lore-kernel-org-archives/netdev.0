From: Roland Dreier <rolandd@cisco.com>
Subject: Re: Timeline of IPoIB performance
Date: Mon, 10 Oct 2005 14:03:26 -0700
Message-ID: <52ek6tf5k1.fsf@cisco.com>
References: <521x2tgrim.fsf@cisco.com> <20051010200321.GC6633@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
In-Reply-To: <20051010200321.GC6633@mellanox.co.il> (Michael S. Tsirkin's
	message of "Mon, 10 Oct 2005 22:03:22 +0200")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Michael> Disabling irq balancing sometimes helps me make the
    Michael> numbers more stable.

I don't think that's an issue.  I'm running on x86_64, which I don't
think has the kernel irq balancer, and I'm not running a userspace IRQ
balancer.  I can see all the mthca interrupts going to the CPU I set
through the smp_affinity file.

 - R.
