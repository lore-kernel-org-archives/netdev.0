From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 38862] New: No support for DGE-530T Rev C1
Date: Wed, 6 Jul 2011 14:37:09 -0700
Message-ID: <20110706143709.0f5ab7d6.akpm@linux-foundation.org>
References: <bug-38862-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: jameshenderson@ruggedcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60085 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756325Ab1GFVhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 17:37:13 -0400
In-Reply-To: <bug-38862-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 6 Jul 2011 16:05:36 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=38862
> 
>            Summary: No support for DGE-530T Rev C1
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.39.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: jameshenderson@ruggedcom.com
>         Regression: No
> 
> 
> The kernel support DGE-530T REV B2 through the skge driver.  The PCI device id
> of REV-B2 is 1186:4302.  Rev C1 has a PCI device id of 1186:4302.  No driver in
> the current kernel supports this device id/vendor combination.  Furthermore,
> this device is not even listed in the device database ->
> http://www.pcidatabase.com/vendor_details.php?id=921 .
> 
> On the chip is the following information:
> D-Link
> DLG10028C
> A8A34A1
> GA50 TAIWAN
> 
> A sticker on the card reads:
> DGE-530T Rev C1
> 
> I am including a picture I took of the card.
> 

Did you test simply adding that device to the driver?

--- a/drivers/net/skge.c~a
+++ a/drivers/net/skge.c
@@ -89,6 +89,7 @@ static DEFINE_PCI_DEVICE_TABLE(skge_id_t
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_YU) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, PCI_DEVICE_ID_DLINK_DGE510T) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },	/* DGE-530T */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4302) },	/* DGE-530T Rev C1 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4320) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x5005) }, /* Belkin */
 	{ PCI_DEVICE(PCI_VENDOR_ID_CNET, PCI_DEVICE_ID_CNET_GIGACARD) },
_

