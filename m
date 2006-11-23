From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.19-rc6 : Spontaneous reboots, stack overflows - seems to
 implicate xfs, scsi, networking, SMP
Date: Thu, 23 Nov 2006 11:54:03 -0800 (PST)
Message-ID: <20061123.115403.84973519.davem@davemloft.net>
References: <20061123070837.GV11034@melbourne.sgi.com>
	<200611231416.03387.netdev@axxeo.de>
	<1164307020.3147.3.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, dgc@sgi.com, jesper.juhl@gmail.com,
	chatz@melbourne.sgi.com, linux-kernel@vger.kernel.org,
	xfs@oss.sgi.com, xfs-masters@oss.sgi.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: arjan@infradead.org
In-Reply-To: <1164307020.3147.3.camel@laptopd505.fenrus.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arjan van de Ven <arjan@infradead.org>
Date: Thu, 23 Nov 2006 19:37:00 +0100

> On Thu, 2006-11-23 at 14:16 +0100, Ingo Oeser wrote:
> > Hi there,
> > 
> > David Chinner schrieb:
> > > If the softirqs were run on a different stack, then a lot of these
> 
> softirqs DO run on their own stack!

This is a platform specific assertion :-)
