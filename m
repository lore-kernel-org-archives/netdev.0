From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 0/2] xen/net: limit number of tx/rx queues
Date: Tue, 10 Jan 2017 13:54:22 +0000
Message-ID: <20170110135422.GL1100@citrix.com>
References: <20170110133252.5346-1-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
        <netdev@vger.kernel.org>, <boris.ostrovsky@oracle.com>,
        <wei.liu2@citrix.com>, <paul.durrant@citrix.com>
To: Juergen Gross <jgross@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170110133252.5346-1-jgross@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 10, 2017 at 02:32:50PM +0100, Juergen Gross wrote:
> The Xen network frontend/backend supports multiple tx/rx queues for one
> virtual interface. The number of queues supported by the backend is
> set to the number of cpus of the backend driver domain (usually dom0)
> and the number of queues requested by the frontend is limited by the
> number of vcpus of the related guest.
> 
> On large systems this can lead to ridiculous large number of queues
> exhausting the required number of grant pages rather quick.
> 
> To avoid this limit the default maximum on both sides to 8. Both
> frontend and backend maximum can be individually tuned via module
> parameters.
> 
> Juergen Gross (2):
>   xen/netfront: set default upper limit of tx/rx queues to 8
>   xen/netback: set default upper limit of tx/rx queues to 8
> 

Acked-by: Wei Liu <wei.liu2@citrix.com>
