From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: Re: TSO and IPoIB performance degradation
Date: Wed, 8 Mar 2006 14:53:11 +0200
Message-ID: <20060308125311.GE17618@mellanox.co.il>
References: <1141776697.6119.938.camel@localhost>
	<20060307.161808.60227862.davem@davemloft.net>
	<adaacc1raz9.fsf@cisco.com>
	<20060307.172336.107863253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org,
	shemminger@osdl.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060307.172336.107863253.davem@davemloft.net>
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

Quoting r. David S. Miller <davem@davemloft.net>:
> Subject: Re: Re: TSO and IPoIB performance degradation
> 
> From: Roland Dreier <rdreier@cisco.com>
> Date: Tue, 07 Mar 2006 17:17:30 -0800
> 
> > The reason TSO comes up is that reverting the patch described below
> > helps (or helped at some point at least) IPoIB throughput quite a bit.
> 
> I wish you had started the thread by mentioning this specific patch

Er, since you mention it, the first message in thread did include this link:
http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=314324121f9b94b2ca657a494cf2b9cb0e4a28cc
and I even pasted the patch description there, but oh well.

Now that Roland helped us clear it all up, and now that it has been clarified
that reverting this patch gives us back most of the performance, is the answer
to my question the same?

What I was trying to figure out was, how can we re-enable the trick without
hurting TSO? Could a solution be to simply look at the frame size, and call
tcp_send_delayed_ack if the frame size is small?

-- 
Michael S. Tsirkin
Staff Engineer, Mellanox Technologies
