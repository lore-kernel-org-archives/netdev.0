From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: PCI VPD size
Date: Fri, 24 Oct 2008 14:18:38 -0700
Message-ID: <200810241418.38733.jbarnes@virtuousgeek.org>
References: <20081024125035.4ebad408@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Benjamin Li" <benli@broadcom.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20081024125035.4ebad408@extreme>
Content-Disposition: inline
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, October 24, 2008 12:50 pm Stephen Hemminger wrote:
> Why did you choose to limit VPD access by using PCI quirks:
>  
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h
>=99cb233d60cbe644203f19938c729ea2bb004d70
>
> Rather than controlling size in the device driver which is what my
> patches (which seem to have been ignored) did:
>   http://marc.info/?l=linux-netdev&m=122393195716363&w=2
>
> The problem with the quirk scheme is that it means putting more
> per device settings in a location farther away in the source code
> than the underlying device driver.

The last status I received on that was a comment from Jeff about assuming the 
maximum size for the VPD space.  That's the whole reason we have the quirks: 
on many devices accessing beyond the end of VPD space can cause a device hang.  
And since that space is available from a sysfs file we need to be extra 
careful.

Other than that, your patches looked fine, I was just waiting for you to 
address that last comment.

-- 
Jesse Barnes, Intel Open Source Technology Center
