From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 6/9] net: use core MTU range checking in virt
 drivers
Date: Fri, 21 Oct 2016 11:09:09 +0100
Message-ID: <20161021100909.GS2639@citrix.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161020175524.6184-1-jarod@redhat.com>
 <20161020175524.6184-7-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <virtualization@lists.linux-foundation.org>,
        "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Shrikrishna Khare <skhare@vmware.com>,
        "VMware, Inc." <pv-drivers@vmware.com>,
        Wei Liu <wei.liu2@citrix.com>,
        Paul Durrant <paul.durrant@citrix.com>,
        David Kershner <david.kershner@unisys.com>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161020175524.6184-7-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2016 at 01:55:21PM -0400, Jarod Wilson wrote:
> hyperv_net:
> - set min/max_mtu, per Haiyang, after rndis_filter_device_add
> 
> virtio_net:
> - set min/max_mtu
> - remove virtnet_change_mtu
> 
> vmxnet3:
> - set min/max_mtu
> 
> xen-netback:
> - min_mtu = 0, max_mtu = 65517
> 
> xen-netfront:
> - min_mtu = 0, max_mtu = 65535
> 
> unisys/visor:
> - clean up defines a little to not clash with network core or add
>   redundat definitions
> 
> CC: netdev@vger.kernel.org
> CC: virtualization@lists.linux-foundation.org
> CC: "K. Y. Srinivasan" <kys@microsoft.com>
> CC: Haiyang Zhang <haiyangz@microsoft.com>
> CC: "Michael S. Tsirkin" <mst@redhat.com>
> CC: Shrikrishna Khare <skhare@vmware.com>
> CC: "VMware, Inc." <pv-drivers@vmware.com>
> CC: Wei Liu <wei.liu2@citrix.com>
> CC: Paul Durrant <paul.durrant@citrix.com>
> CC: David Kershner <david.kershner@unisys.com>
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
