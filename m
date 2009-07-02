From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general][PATCH 2/2] mlx4: ConnectX multi functional device
	support
Date: Thu, 02 Jul 2009 10:05:23 -0700
Message-ID: <ada7hyr10do.fsf@cisco.com>
References: <4A3A34F5.9030800@mellanox.co.il>
	<4A4C816A.2040506@mellanox.co.il> <adabpo317c5.fsf@cisco.com>
	<4A4CD0D7.6070409@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: Tziporet Koren <tziporet@dev.mellanox.co.il>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <4A4CD0D7.6070409@mellanox.co.il> (Tziporet Koren's message of
	"Thu, 02 Jul 2009 18:23:03 +0300")
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


 > The risk is very low, however without it our new device coming in July
 > will not work on the new kernel :-(
 > And if not on 2.6.31 can you at list queue it on your future work tree?

Well, I need to think over the patch a little more.  The risk is
certainly not zero, since we are changing device initialization for all
mlx4 devices.  And I'm not sure if missing 2.6.31 support is that big a
deal for you, is it?  How many users do you have building their own
upstream kernels?  You're just going to tell everyone to use OFED
anyway, right?

 - R.
