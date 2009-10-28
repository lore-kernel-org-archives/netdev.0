From: Bhavesh Davda <bhavesh@vmware.com>
Subject: RE: [Pv-drivers] [PATCH] vmxnet3: remove duplicate #include
Date: Wed, 28 Oct 2009 09:32:40 -0700
Message-ID: <8B1F619C9F5F454E81D90D3C161698D7017DFA9FEC@EXCH-MBX-3.vmware.com>
References: <alpine.LRH.2.00.0910280910250.24555@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"weiyi.huang@gmail.com" <weiyi.huang@gmail.com>
To: Shreyas Bhatewara <sbhatewara@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:47671 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754996AbZJ1Qcg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2009 12:32:36 -0400
In-Reply-To: <alpine.LRH.2.00.0910280910250.24555@sbhatewara-dev1.eng.vmware.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correction:

< Signed-off-by: Bhavesh Davda <davda@vmware.com>
> Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>

Thanks

- Bhavesh
 
Bhavesh P. Davda

> -----Original Message-----
> From: pv-drivers-bounces@vmware.com [mailto:pv-drivers-
> bounces@vmware.com] On Behalf Of Shreyas Bhatewara
> Sent: Wednesday, October 28, 2009 9:31 AM
> To: netdev@vger.kernel.org
> Cc: pv-drivers@vmware.com; weiyi.huang@gmail.com
> Subject: [Pv-drivers] [PATCH] vmxnet3: remove duplicate #include
> 
> 
> Remove duplicate headerfile includes from vmxnet3_int.h
> 
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
> Signed-off-by: Bhavesh Davda <davda@vmware.com>
> 
> ---
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_int.h
> b/drivers/net/vmxnet3/vmxnet3_int.h
> index 3c0d70d..4450816 100644
> --- a/drivers/net/vmxnet3/vmxnet3_int.h
> +++ b/drivers/net/vmxnet3/vmxnet3_int.h
> @@ -27,16 +27,11 @@
>  #ifndef _VMXNET3_INT_H
>  #define _VMXNET3_INT_H
> 
> -#include <linux/types.h>
>  #include <linux/ethtool.h>
>  #include <linux/delay.h>
> -#include <linux/device.h>
>  #include <linux/netdevice.h>
>  #include <linux/pci.h>
> -#include <linux/ethtool.h>
>  #include <linux/compiler.h>
> -#include <linux/module.h>
> -#include <linux/moduleparam.h>
>  #include <linux/slab.h>
>  #include <linux/spinlock.h>
>  #include <linux/ioport.h>
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
