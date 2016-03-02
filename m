From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH for-next 01/10] net/core: Add support for configuring VF GUIDs
Date: Wed, 2 Mar 2016 20:40:09 +0200
Message-ID: <CAJ3xEMh5vJAZVO03=rRVCvqqXzXvah3idrMtMQfFP-wBxR7R_Q@mail.gmail.com>
References: <1456851143-138332-1-git-send-email-eli@mellanox.com>
	<1456851143-138332-2-git-send-email-eli@mellanox.com>
	<20160301173751.GA25176@obsidianresearch.com>
	<20160301174951.GA19366@x-vnc01.mtx.labs.mlnx>
	<20160301182516.GA12495@obsidianresearch.com>
	<CAJ3xEMgrAUCj7PS6fegmuSUsjMruH3gzSHZmuzAX+ZbHZOpL9w@mail.gmail.com>
	<56D719E3.2000206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56D719E3.2000206-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 2, 2016 at 6:50 PM, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> Exactly *what* provisioning system tries to set the VF_MAC on an IPoIB
> interface and expects it to set the GUID of an underlying IB device?

The provisioning system need not be fully aware in all their
components this is IB here, there's PCI linkage that tells these are
VFs of this PF and they have to be used for these VMs.

>> along with the fully IB aware solution where the
>> upper level does provision IB GUIDs.

> There has never been upstream support for this MAC->GUID stuff you refer
> to.  I'm not convinced we should add it now versus just doing things
> right, period.

We **are** doing things right with the new ndo.

Using the small MAC->GUID addition, people could be using non-modified
(or almost non-modified) provisioning systems that assign SRIOV VMs
with a MACs --- just use these patches on their hosts and get DHCP
server supplying IP addresses based on the derived GUIDs (this is
supported today).
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
