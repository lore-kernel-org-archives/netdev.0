From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH v2 net-next 2/2] qlcnic: Use pci_enable_msix_exact()
 instead of pci_enable_msix()
Date: Fri, 25 Apr 2014 09:43:46 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A46F9EF49@avmb2.qlogic.org>
References: <cover.1398412015.git.agordeev@redhat.com>
 <0a0d5f5c33d86e3777c22c3c1bbd81035660d57c.1398412015.git.agordeev@redhat.com>
 <262CB373A6D1F14F9B81E82F74F77D5A46F9EE54@avmb2.qlogic.org>
 <20140425090029.GA2500@dhcp-26-207.brq.redhat.com>
 <262CB373A6D1F14F9B81E82F74F77D5A46F9EEA2@avmb2.qlogic.org>
 <20140425094349.GA6397@dhcp-26-207.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-pci <linux-pci@vger.kernel.org>
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140425094349.GA6397@dhcp-26-207.brq.redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Alexander Gordeev [mailto:agordeev@redhat.com]
> Sent: Friday, April 25, 2014 3:14 PM
> To: Shahed Shaikh
> Cc: linux-kernel; Dept-HSG Linux NIC Dev; netdev; linux-pci
> Subject: [PATCH v2 net-next 2/2] qlcnic: Use pci_enable_msix_exact()
> instead of pci_enable_msix()
> 
> As result of deprecation of MSI-X/MSI enablement functions
> pci_enable_msix() and pci_enable_msi_block() all drivers using these two
> interfaces need to be updated to use the new pci_enable_msi_range()  or
> pci_enable_msi_exact() and pci_enable_msix_range() or
> pci_enable_msix_exact() interfaces.
> 
> Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Cc: Dept-HSGLinuxNICDev@qlogic.com
> Cc: netdev@vger.kernel.org
> Cc: linux-pci@vger.kernel.org
> 
> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
Acked-by: Shahed Shaikh <shahed.shaikh@qlogic.com>

Thanks,
Shahed
