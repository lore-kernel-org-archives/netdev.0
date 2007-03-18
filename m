From: ebiederman@lnxi.com (Eric W. Biederman)
Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Sun, 18 Mar 2007 16:24:23 -0600
Message-ID: <m3tzwi8a20.fsf@maxwell.lnxi.com>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
	<20070318202559.GD11078@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070318202559.GD11078@mellanox.co.il> (Michael S. Tsirkin's
	message of "Sun, 18 Mar 2007 22:25:59 +0200")
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

"Michael S. Tsirkin" <mst@dev.mellanox.co.il> writes:

>> > Why is neighbour->dev changed here?
>> 
>> It holds reference to device and prevents its destruction.
>> If dst is held somewhere, we cannot destroy the device and deadlock
>> while unregister.
>
> BTW, can this ever happen for the loopback device itself?
> Is it ever unregistered?

Well I don't think the loopback device is currently but as soon
as we get network namespace support we will have multiple loopback
devices and they will get unregistered when we remove the network
namespace.

Eric
