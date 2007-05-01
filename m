From: Bill Fink <billfink@mindspring.com>
Subject: Re: [ofa-general] Re: IPoIB forwarding
Date: Tue, 1 May 2007 01:57:31 -0400
Message-ID: <20070501015731.3568d28b.billfink@mindspring.com>
References: <6.1.2.0.2.20070423160212.12db6400@mail.llnl.gov>
	<20070425124652.GG1624@mellanox.co.il>
	<6.1.2.0.2.20070426083410.1389d9e0@mail.llnl.gov>
	<20070426161409.GF15540@mellanox.co.il>
	<6.1.2.0.2.20070426095112.138e9a68@mail.llnl.gov>
	<20070426180618.GJ15540@mellanox.co.il>
	<6.1.2.0.2.20070427115435.13ea5ec0@mail.llnl.gov>
	<46325DF3.2050203@hp.com>
	<6.1.2.0.2.20070427152027.13fe46d0@mail.llnl.gov>
	<46327A07.1000404@hp.com>
	<6.1.2.0.2.20070427153952.13fc7d08@mail.llnl.gov>
	<4632894D.40705@hp.com>
	<20070428025117.a3b1200a.billfink@mindspring.com>
	<46362244.9030406@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bryan Lawver <lawver1@llnl.gov>,
	"Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	general@lists.openfabrics.org,
	Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:52184 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946594AbXEAF5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 01:57:37 -0400
In-Reply-To: <46362244.9030406@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Apr 2007, Rick Jones wrote:

> > What version of the myri10ge driver is this?  With the 1.2.0 version
> > that comes with the 2.6.20.7 kernel, there is no myri10ge_lro module
> > parameter.
> > 
> > [root@lang2 ~]# modinfo myri10ge | grep -i lro
> > [root@lang2 ~]# 
> > 
> > And I've been testing IP forwarding using two Myricom 10-GigE NICs
> > without setting any special modprobe parameters.
> 
> 
> Ethtool -i on the interface reports 1.2.0 as the driver version.

Perhaps it would be useful to have different version strings for
the in-kernel Linux version and the Myricom externally provided
version.  Just a thought.

						-Bill
