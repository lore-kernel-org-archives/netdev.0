From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH V3] netxen: fix ethtool rx_dropped information in
 ethtool get_ethtool_stats()
Date: Fri, 18 Jul 2014 18:21:44 +0000
Message-ID: <C562D0E12CBDE44E8A0CCAB77060096701283AD344@AVMB1.qlogic.org>
References: <1405655009-18975-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	"ethan.kernel@gmail.com" <ethan.kernel@gmail.com>
To: Ethan Zhao <ethan.zhao@oracle.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405655009-18975-1-git-send-email-ethan.zhao@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Ethan Zhao [mailto:ethan.zhao@oracle.com]
> Sent: Friday, July 18, 2014 9:13 AM
> To: Manish Chopra; Sony Chacko; Rajesh Borundia; netdev
> Cc: linux-kernel; ethan.kernel@gmail.com; Ethan Zhao
> Subject: [PATCH V3] netxen: fix ethtool rx_dropped information in ethtool
> get_ethtool_stats()
> 
> netxen driver has implemented netxen_nic_get_ethtool_stats() interface,
> but it doesn't collect stats.rxdropped in driver, so we will get different
> rx_dropped statistic information while using ifconfig and ethtool.
> this patch fills stats.rxdropped field with data from net core with
> dev_get_stats() just as ixgbe driver did for some of its stats.

I think ethtool stats are adapter specific. Driver does not maintain
rx_dropped stats and we also don't get it from adapter.  I am not
sure if ethtool stats should match ifconfig stats as ifconfig also
adds net core stats to adapter stats.

If ethtool stats should report same values as ifconfig stats then
we may also need to fix tx_dropped statistics.

Thanks,
Rajesh
