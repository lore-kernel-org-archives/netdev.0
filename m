From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: RE: [PATCH -next] vmxnet3: use dev_dbg, fix build for CONFIG_BLOCK=n
Date: Thu, 15 Oct 2009 15:37:23 -0700
Message-ID: <89E2752CFA8EC044846EB8499819134101741BA4C0@EXCH-MBX-4.vmware.com>
References: <20091015152538.74a1cb15.sfr@canb.auug.org.au>
 <4AD7A24F.6000900@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763100AbZJOWiF@vger.kernel.org>
In-Reply-To: <4AD7A24F.6000900@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Randy Dunlap [mailto:randy.dunlap@oracle.com]
> Sent: Thursday, October 15, 2009 3:30 PM
> To: Stephen Rothwell
> Cc: linux-next@vger.kernel.org; LKML; netdev; David Miller; Shreyas
> Bhatewara; pv-drivers@vmware.com
> Subject: [PATCH -next] vmxnet3: use dev_dbg, fix build for
> CONFIG_BLOCK=n
> 
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> vmxnet3 was using dprintk() for debugging output.  This was
> defined in <linux/dst.h> and was the only thing that was
> used from that header file.  This caused compile errors
> when CONFIG_BLOCK was not enabled due to bio* and BIO*
> uses in the header file, so change this driver to use
> dev_dbg() for debugging output.
> 
> include/linux/dst.h:520: error: dereferencing pointer to incomplete
> type
> include/linux/dst.h:520: error: 'BIO_POOL_BITS' undeclared (first use
> in this function)
> include/linux/dst.h:521: error: dereferencing pointer to incomplete
> type
> include/linux/dst.h:522: error: dereferencing pointer to incomplete
> type
> include/linux/dst.h:525: error: dereferencing pointer to incomplete
> type
> make[4]: *** [drivers/net/vmxnet3/vmxnet3_drv.o] Error 1
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>


Thanks for the changes Randy, appreciate it.

->Shreyas
