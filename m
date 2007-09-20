From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [Bug,
	PATCH and another Bug] Was: Fix refcounting problem
	with netif_rx_reschedule()
Date: Thu, 20 Sep 2007 11:24:01 +0530
Message-ID: <OF035DCEA7.EE6D8D3A-ON6525735C.001FC9D4-6525735C.00206959@in.ibm.com>
References: <20070919.221224.26966518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, rdreier@cisco.com, ossthema@de.ibm.com,
	general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070919.221224.26966518.davem@davemloft.net>
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

Ran 4/16/64 thread iperf on latest bits with this patch and no issues after
30 mins. I used to
consistently get the bug within 1-2 mins with just 4 threads prior to this
patch.

Tested-by: Krishna Kumar <krkumar2@in.ibm.com>
(if any value in that)

thanks,

- KK

David Miller <davem@davemloft.net> wrote on 09/20/2007 10:42:24 AM:

> From: Krishna Kumar2 <krkumar2@in.ibm.com>
> Date: Thu, 20 Sep 2007 10:40:33 +0530
>
> > I like the clean changes made by Dave to fix this, and will test it
> > today (if I can get my crashed system to come up).
>
> I would very much appreciate this testing, as I'm rather sure we've
> plugged up the most serious holes at this point.
