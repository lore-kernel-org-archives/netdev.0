From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: [PATCH 6/17 linux-2.6.7-rc2] prism54: Kernel compatibility
Date: Thu, 03 Jun 2004 17:31:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20040603172343.00acf4a8@pop.t-online.de>
References: <5.1.0.14.2.20040602221238.00adfbf8@pop.t-online.de>
 <200405310213.53280.margitsw@t-online.de>
 <200405310213.53280.margitsw@t-online.de>
 <5.1.0.14.2.20040602221238.00adfbf8@pop.t-online.de> <40BE386A.1080201@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40BE386A.1080201@pobox.com>
References: <5.1.0.14.2.20040602221238.00adfbf8@pop.t-online.de>
 <200405310213.53280.margitsw@t-online.de>
 <200405310213.53280.margitsw@t-online.de>
 <5.1.0.14.2.20040602221238.00adfbf8@pop.t-online.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 16:28 02.06.2004 -0400, you wrote:
>Margit Schubert-While wrote:
>>At 16:03 02.06.2004 -0400, you wrote:
>>
>>>Margit Schubert-While wrote:
>>>
>>>>2004-03-20      Margit Schubert-While <margitsw@t-online.de>
>>>>* isl_38xx.[ch], isl_ioctl.c, islpci_dev.[ch], islpci_eth.c
>>>>   islpci_hotplug.c, islpci_mgt.[ch], oid_mgt.c, prismcompat.h:
>>>>   Adopt new prism54 kernel compatibility.
>>>>   Remove remaining kernel version ifdefs.
>>>
>>>
>>>
>>>>@@ -325,11 +320,7 @@
>>>>         printk(KERN_DEBUG "%s: uploading firmware...\n", 
>>>> priv->ndev->name);
>>>>
>>>>         rc = isl38xx_upload_firmware(priv->firmware,
>>>>-#if (LINUX_VERSION_CODE > KERNEL_VERSION(2,5,75))
>>>>-               &priv->pdev->dev,
>>>>-#else
>>>>-               pci_name(priv->pdev),
>>>>-#endif
>>>
>>>
>>>Rejected, both 2.4 and 2.6 should use pci_name() directly in the code
>>>
>>>Please resend patches 6 through 17, after fixing patches 6, 12, and 14.
>>>
>>>         Jeff
>>Absolutely not !
>>Parameter for 2.4 = char *, param for for 2.6 = struct dev *
>>LOL
>>Margit
>
>[jgarzik@sata repo]$ grep -w pci_name linux-2.[46]/include/linux/pci.h
>linux-2.4/include/linux/pci.h:static inline char *pci_name(struct pci_dev 
>*pdev)
>linux-2.6/include/linux/pci.h:static inline char *pci_name(struct pci_dev 
>*pdev)

I was not talking about pci_name, I was talking about the 3rd param to
request_firmware which is char * in 2.4, struct dev * in 2.6.
Patch 16 cleans this area up.
If it makes it easier, I can put together patches 5 and 16. Your call.

Errm, what's wrong with patches 12 and 14 ?
