From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169 NAPI addition
Date: Tue, 20 Apr 2004 18:25:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040420182501.A31888@electric-eye.fr.zoreil.com>
References: <20040419224911.A17362@electric-eye.fr.zoreil.com> <OF22F0D968.EDCFE67B-ON87256E7C.0053AE89-86256E7C.005628A4@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon D Mason <jonmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF22F0D968.EDCFE67B-ON87256E7C.0053AE89-86256E7C.005628A4@us.ibm.com>; from jonmason@us.ibm.com on Tue, Apr 20, 2004 at 09:45:07AM -0600
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon D Mason <jonmason@us.ibm.com> :
[...]
> I assume you are referring to the driver being used in weakly ordered 
> memory model machines.  To address this I added a rmb() after the update 
> to the interrupt mask.

Nonono, it is a PCI thing. Writes to (pci-)MMIO registers are posted and
typically require a read in the MMIO range (or "some" time) to be committed
to the final device. (pci-)IO accesses do not exhibit this property.

--
Ueimor
