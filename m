From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 14 Jul 2010 11:03:17 -0700
Message-ID: <4C3DFBE5.2020705@goop.org>
References: <1278990388.32650.22.camel@eng-rhel5-64>	<20100714094952.GA16209@kroah.com>	<F1354E79A137A24CBA60059AA65CB1B802A34EEB67@EXCH-MBX-2.vmware.com> <20100714.105423.226778756.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: pthakkar@vmware.com, pv-drivers@vmware.com, greg@kroah.com,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, hch@infradead.org,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100714.105423.226778756.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/14/2010 10:54 AM, David Miller wrote:
> And doing what you're doing is foolish on so many levels.  One more
> duplication of code, one more place for unnecessary bugs to live, one
> more place that might need optimizations and thus require duplication
> of even more work people have done over the years.
>   

Not to mention calling a function "MoveMemory" when it doesn't do a
memmove is just cruel.

    J
