From: "Diego Guella" <diego.guella@sircomtech.com>
Subject: Re: [ofa-general] [PATCH 2.6.25] RDMA/cxgb3: Fail loopbackconnections.
Date: Wed, 13 Feb 2008 10:18:53 +0100
Message-ID: <015c01c86e21$75317210$05c8a8c0@DIEGO>
References: <20080212220929.24442.76874.stgit@dell3.ogc.int>
	<adafxvxvgz3.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: "Steve Wise" <swise@opengridcomputing.com>,
	"Roland Dreier" <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
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

One question below


----- Original Message ----- 
From: "Roland Dreier" <rdreier@cisco.com>
To: "Steve Wise" <swise@opengridcomputing.com>
Cc: <netdev@vger.kernel.org>; <linux-kernel@vger.kernel.org>; <general@lists.openfabrics.org>
Sent: Wednesday, February 13, 2008 1:26 AM
Subject: Re: [ofa-general] [PATCH 2.6.25] RDMA/cxgb3: Fail loopbackconnections.


> applied, although:
> 
> > +static void is_loopback_dst(struct iw_cm_id *cm_id)
> > +{
> > + struct net_device *dev;
> > + 
> > + dev = ip_dev_find(&init_net, cm_id->remote_addr.sin_addr.s_addr);
> > + if (!dev)
> > + return 0;

how can a static void function return 0?
%)

> > + dev_put(dev);
> > + return 1;

same here
