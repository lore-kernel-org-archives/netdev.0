From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: Kernel stack overflow on 2.6.9-rc2
Date: Tue, 14 Sep 2004 22:43:55 +0300
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200409142243.55949.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200409141723.35009.vda@port.imtp.ilyichevsk.odessa.ua> <20040914163347.GE3197@schnapps.adilger.int> <Pine.LNX.4.53.0409141340540.4262@chaos>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S269755AbUINTsA@vger.kernel.org>
To: root@chaos.analogic.com, Andreas Dilger <adilger@clusterfs.com>
In-Reply-To: <Pine.LNX.4.53.0409141340540.4262@chaos>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

On Tuesday 14 September 2004 20:55, Richard B. Johnson wrote:
> Has anybody ever explained why there is an attempt to
> minimize the size of the kernel stack? Temporary data
> allocation on the stack is FREE! The compiler just
> adjusts offsets for data. Even dynamic data-allocation
> takes only one instruction, (subl %reg, %esp).

IIRC it is done in order to be able to support large number
of threads on 32-bit machines and to avoid needing to do
a order-1 allocation at fork().
--
vda
