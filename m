From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PCI VPD size
Date: Fri, 24 Oct 2008 21:52:48 +0100
Message-ID: <20081024205246.GR7331@solarflare.com>
References: <20081024125035.4ebad408@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>,
	Benjamin Li <benli@broadcom.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081024125035.4ebad408@extreme>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Why did you choose to limit VPD access by using PCI quirks:
>   http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=99cb233d60cbe644203f19938c729ea2bb004d70
> 
> Rather than controlling size in the device driver which is what my
> patches (which seem to have been ignored) did:
>   http://marc.info/?l=linux-netdev&m=122393195716363&w=2
> 
> The problem with the quirk scheme is that it means putting more
> per device settings in a location farther away in the source code
> than the underlying device driver.

The limit needs to be set in quirks because VPD I/O beyond that limit
causes those devices to stop responding.  If I understand correctly,
you're only reducing the limit as an optimisation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
