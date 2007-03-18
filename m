From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Mon, 19 Mar 2007 00:36:53 +0200
Message-ID: <20070318223653.GO11078@mellanox.co.il>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
	<20070318202559.GD11078@mellanox.co.il>
	<m3tzwi8a20.fsf@maxwell.lnxi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederman@lnxi.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <m3tzwi8a20.fsf@maxwell.lnxi.com>
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

> Quoting Eric W. Biederman <ebiederman@lnxi.com>:
> Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
> 
> "Michael S. Tsirkin" <mst@dev.mellanox.co.il> writes:
> 
> >> > Why is neighbour->dev changed here?
> >> 
> >> It holds reference to device and prevents its destruction.
> >> If dst is held somewhere, we cannot destroy the device and deadlock
> >> while unregister.
> >
> > BTW, can this ever happen for the loopback device itself?
> > Is it ever unregistered?
> 
> Well I don't think the loopback device is currently but as soon
> as we get network namespace support we will have multiple loopback
> devices and they will get unregistered when we remove the network
> namespace.

Hmm. Then the code moving dst->dev to point to the loopback
device will have to be fixed too. I'll post a patch a bit later.

-- 
MST
