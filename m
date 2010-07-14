From: David Miller <davem@davemloft.net>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 14 Jul 2010 10:54:23 -0700 (PDT)
Message-ID: <20100714.105423.226778756.davem@davemloft.net>
References: <1278990388.32650.22.camel@eng-rhel5-64>
	<20100714094952.GA16209@kroah.com>
	<F1354E79A137A24CBA60059AA65CB1B802A34EEB67@EXCH-MBX-2.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, sbhatewara@vmware.com, hch@infradead.org,
	shemminger@vyatta.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: pthakkar@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45297
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752502Ab0GNRyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 13:54:08 -0400
In-Reply-To: <F1354E79A137A24CBA60059AA65CB1B802A34EEB67@EXCH-MBX-2.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pankaj Thakkar <pthakkar@vmware.com>
Date: Wed, 14 Jul 2010 10:18:22 -0700

> The plugin is guest agnostic and hence we did not want to rely on
> any kernel provided functions.

While I disagree entirely with this kind of approach, even that
doesn't justify what you're doing here.

memcpy() and memset() are on a much more fundamental ground than
"kernel provided functions".  They had better be available no matter
where you build this thing.

And doing what you're doing is foolish on so many levels.  One more
duplication of code, one more place for unnecessary bugs to live, one
more place that might need optimizations and thus require duplication
of even more work people have done over the years.
