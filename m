From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC 05/77] PCI/MSI: Convert pci_msix_table_size() to a
 public interface
Date: Mon, 7 Oct 2013 14:10:43 -0400
Message-ID: <20131007181043.GA27396@htj.dyndns.org>
References: <cover.1380703262.git.agordeev@redhat.com>
 <e8b51bd48c24d0fc4ee8adea5c138c9bf84191e9.1380703262.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
	Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Andy King <acking-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, Jon Mason <jon.mason-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Matt Porter <mporter-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iss_storagedev-VXdhtT5mjnY@public.gmane.org,
	linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	Solarflare linux maintainers <linux-net-drivers-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	"VMware, Inc." <pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, linux-sc
To: Alexander Gordeev <agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e8b51bd48c24d0fc4ee8adea5c138c9bf84191e9.1380703262.git.agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Wed, Oct 02, 2013 at 12:48:21PM +0200, Alexander Gordeev wrote:
> Make pci_msix_table_size() to return a error code if the device
> does not support MSI-X. This update is needed to facilitate a
> forthcoming re-design MSI/MSI-X interrupts enabling pattern.
> 
> Device drivers will use this interface to obtain maximum number
> of MSI-X interrupts the device supports and use that value in
> the following call to pci_enable_msix() interface.
> 
> Signed-off-by: Alexander Gordeev <agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Hmmm... I probably missed something but why is this necessary?  To
discern between -EINVAL and -ENOSPC?  If so, does that really matter?

Thanks.

-- 
tejun
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
