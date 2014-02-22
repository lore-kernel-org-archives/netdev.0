From: Alexander Gordeev <agordeev@redhat.com>
Subject: Re: [PATCH net-next 28/35] qlcnic: Use pci_enable_msix_range()
 instead of pci_enable_msix()
Date: Sat, 22 Feb 2014 10:24:26 +0100
Message-ID: <20140222092425.GA27897@dhcp-26-207.brq.redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
 <cb8eb41f672c62d1149c375bdaf97ca3328703f9.1392717503.git.agordeev@redhat.com>
 <1393029870.15717.71.camel@deadeye.wl.decadent.org.uk>
 <1393030127.15717.72.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Himanshu Madhani <himanshu.madhani@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1393030127.15717.72.camel@deadeye.wl.decadent.org.uk>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 22, 2014 at 12:48:47AM +0000, Ben Hutchings wrote:
> Sorry, I'm confused and this does work.  But I wonder whether it is
> really an improvement over using the old API.

Slightly, as far as I am concerned - we just exchange tri-state oddity
to re-enable MSI-X oddity. We're not going to improve drivers that can
not work with any number of MSI-Xs from a range, like this one.

> Ben.

-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
