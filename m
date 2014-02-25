From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH] mlx4: Use GFP_NOFS calls during the ipoib TX path when
 creating the QP
Date: Wed, 26 Feb 2014 00:20:04 +0200
Message-ID: <CAJZOPZJpRYKw7Dskr21QP_d6c7ySS+mi-g_19pNJYm0Gq=ZY+g@mail.gmail.com>
References: <alpine.LNX.2.00.1402211450410.1192@pobox.suse.cz>
	<CAJZOPZK4Ah+nKPWnX3=yM43jbf586GYJ+fh0-OL4bOnqKK8v8A@mail.gmail.com>
	<alpine.LNX.2.00.1402252307130.5180@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <roland@kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1402252307130.5180@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 26, 2014 at 12:11 AM, Jiri Kosina <jkosina@suse.cz> wrote:
> On Tue, 25 Feb 2014, Or Gerlitz wrote:

>> And what happens if you use IPoIB datagram mode, is/why the patch is
>> needed there?

> I admittedly am no infiniband expert, but my understanding is that in
> principle Connected/Datagram mode is about MTU and checksum offloading,

yes, the differences between the mode relate to these aspects, however

> but the TX path is the same. Please correct me if I am wrong.

no, note that your patch only touched drivers/infiniband/ulp/ipoib/ipoib_cm.c
which is basically compiled out if you set CONFIG_INFINIBAND_IPOIB_CM,
so surely the TX path for the datagram vs. connected modes are
different.
