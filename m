From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] [PATCH 2.6.25] RDMA/cxgb3: Fail loopback
	connections.
Date: Tue, 12 Feb 2008 16:26:56 -0800
Message-ID: <adafxvxvgz3.fsf@cisco.com>
References: <20080212220929.24442.76874.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080212220929.24442.76874.stgit@dell3.ogc.int> (Steve Wise's
	message of "Tue, 12 Feb 2008 16:09:29 -0600")
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

applied, although:

 > +static void is_loopback_dst(struct iw_cm_id *cm_id)
 > +{
 > +	struct net_device *dev;
 > +	
 > +	dev = ip_dev_find(&init_net, cm_id->remote_addr.sin_addr.s_addr);
 > +	if (!dev)
 > +		return 0;
 > +	dev_put(dev);
 > +	return 1;
 > +}

is there any way this could trigger when it should, like if I'm trying
to make a connection from one local device to a different local device
(which should work fine)?

 - R.
