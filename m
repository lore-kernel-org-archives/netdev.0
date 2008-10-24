From: Stephen Hemminger <shemminger@vyatta.com>
Subject: PCI VPD size
Date: Fri, 24 Oct 2008 12:50:35 -0700
Message-ID: <20081024125035.4ebad408@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: Jesse Barnes <jbarnes@virtuousgeek.org>,
	"Benjamin Li" <benli@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Why did you choose to limit VPD access by using PCI quirks:
  http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=99cb233d60cbe644203f19938c729ea2bb004d70

Rather than controlling size in the device driver which is what my
patches (which seem to have been ignored) did:
  http://marc.info/?l=linux-netdev&m=122393195716363&w=2

The problem with the quirk scheme is that it means putting more
per device settings in a location farther away in the source code
than the underlying device driver.
