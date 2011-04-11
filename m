From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: rndis: dhcp discover stopped working
Date: Mon, 11 Apr 2011 14:02:47 -0700
Message-ID: <20110411210247.GB15419@kroah.com>
References: <20110411205440.GA4227@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sergey Senozhatsky <sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110411205440.GA4227@swordfish>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 11, 2011 at 11:54:40PM +0300, Sergey Senozhatsky wrote:
> Hello,
> Seems like dhcp discover stopped working with my HTC in "USB-tethering" mode:
> 
> kernel: [   60.670379] usb 2-1.3: new high speed USB device number 4 using ehci_hcd
> kernel: [   60.766779] usb 2-1.3: New USB device found, idVendor=0bb4, idProduct=0c87
> kernel: [   60.766787] usb 2-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
> kernel: [   60.766792] usb 2-1.3: Product: Android Phone
> kernel: [   60.766796] usb 2-1.3: Manufacturer: HTC
> kernel: [   60.766800] usb 2-1.3: SerialNumber: HT082PL07557
> kernel: [   60.861976] Initializing USB Mass Storage driver...
> kernel: [   60.862395] scsi4 : usb-storage 2-1.3:1.0
> kernel: [   60.862965] usbcore: registered new interface driver usb-storage
> kernel: [   60.862972] USB Mass Storage support registered.
> kernel: [   61.865117] scsi 4:0:0:0: Direct-Access     HTC      Android Phone    0100 PQ: 0 ANSI: 2
> kernel: [   61.874518] sd 4:0:0:0: [sdb] Attached SCSI removable disk
> kernel: [   72.129190] usb 2-1.3: USB disconnect, device number 4
> kernel: [   72.454846] usb 2-1.3: new high speed USB device number 5 using ehci_hcd
> kernel: [   72.551186] usb 2-1.3: New USB device found, idVendor=0bb4, idProduct=0ffe
> kernel: [   72.551195] usb 2-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
> kernel: [   72.551200] usb 2-1.3: Product: Android Phone
> kernel: [   72.551205] usb 2-1.3: Manufacturer: HTC
> kernel: [   72.551242] usb 2-1.3: SerialNumber: HT082PL07557
> kernel: [   72.572416] rndis_host 2-1.3:1.0: usb0: register 'rndis_host' at usb-0000:00:1d.0-1.3, RNDIS device, e6:99:59:e3:8c:98
> kernel: [   87.281911] NET: Registered protocol family 10
> kernel: [   87.284969] ADDRCONF(NETDEV_UP): eth0: link is not ready
> dhclient: can't create /var/db/dhclient.leases: No such file or directory
> dhclient: DHCPDISCOVER on usb0 to 255.255.255.255 port 67 interval 8
> kernel: [   98.003895] usb0: no IPv6 routers present
> dhclient: DHCPDISCOVER on usb0 to 255.255.255.255 port 67 interval 8
> dhclient: DHCPDISCOVER on usb0 to 255.255.255.255 port 67 interval 11
> dhclient: DHCPDISCOVER on usb0 to 255.255.255.255 port 67 interval 15
> dhclient: DHCPDISCOVER on usb0 to 255.255.255.255 port 67 interval 19
> dhclient: No DHCPOFFERS received.
> dhclient: No working leases in persistent database - sleeping.
> 
> 
> kernel: .39-rc2-*

Known bug, a patch was posted that fixed this already...

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
