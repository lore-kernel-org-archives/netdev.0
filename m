From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: PCI: make pci_restore_state return void
Date: Fri, 10 Dec 2010 13:07:30 -0800
Message-ID: <20101210130730.29d07c2d@jbarnes-desktop>
References: <1291160606-31494-1-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	linux-media@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>, netdev@vger.kernel.org,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	linux-wireless@vger.kernel.org, Brian King <brking@us.ibm.com>,
	Anil Ravindranath <anil_ravindranath@pmc-sierra.com>,
	linux-scsi@vger.kernel.org, Jaya Kumar <jayakumar.alsa@gmail.com>,
	boyod.yang@siliconmotion.com.cn
To: Jon Mason <jon.mason@exar.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1291160606-31494-1-git-send-email-jon.mason@exar.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 30 Nov 2010 17:43:26 -0600
Jon Mason <jon.mason@exar.com> wrote:

> pci_restore_state only ever returns 0, thus there is no benefit in
> having it return any value.  Also, a large majority of the callers do
> not check the return code of pci_restore_state.  Make the
> pci_restore_state a void return and avoid the overhead.
> 
> Signed-off-by: Jon Mason <jon.mason@exar.com>
> ---

Applied to linux-next, thanks.

-- 
Jesse Barnes, Intel Open Source Technology Center
