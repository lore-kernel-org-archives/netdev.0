From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: [PATCH 22/29] net_dma: poll for a descriptor after allocation
 failure
Date: Mon, 14 Sep 2009 16:00:52 +0100
Message-ID: <129600E5E5FB004392DDC3FB599660D7B5548195@irsmsx504.ger.corp.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
 <20090904023221.32667.70000.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-raid@vger.kernel.org" <linux-raid@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <20090904023221.32667.70000.stgit@dwillia2-linux.ch.intel.com>
Content-Language: en-US
Sender: linux-raid-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Williams, Dan J wrote:
> Handle descriptor allocation failures by polling for a descriptor.  The
> driver will force forward progress when polled.  In the best case this
> polling interval will be the time it takes for one dma memcpy
> transaction to complete.  In the worst case, channel hang, we will need
> to wait 100ms for the cleanup watchdog to fire (ioatdma driver).
> 
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>