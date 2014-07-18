From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/25] Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 09:43:40 -0700
Message-ID: <20140718164340.GA24960@kroah.com>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
	<20140718162213.GC31114@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org,
	linux-pci@vger.kernel.org, dri-devel@lists.freedesktop.org,
	platform-driver-x86@vger.kernel.org, Benoit Taine <benoit.taine@lip6.fr>,
	ath5k-devel@venema.h4ckr.net, linux-acenic@sunsite.dk,
	linux-scsi@vger.kernel.org, users@rt2x00.serialmonkey.com,
	linux-rdma@vger.kernel.org, ath10k@lists.infradead.org,
	linux-hippi@sunsite.dk, industrypack-devel@lists.sourceforge.net,
	linux-wireless@vger.kernel.org, xen-devel@lists.xenproject.org,
	MPT-FusionLinux.pdl@avagotech.com, ath9k-devel@venema.h4ckr.net,
	wil6210@qca.qualcomm.com, linux-pcmcia@lists.infradead.org,
	linux-can@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-mmc@vger.kernel.org,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-crypto@vger.kernel.org, devel@linuxdriverproject.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20140718162213.GC31114@tuxdriver.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 18, 2014 at 12:22:13PM -0400, John W. Linville wrote:
> On Fri, Jul 18, 2014 at 05:26:47PM +0200, Benoit Taine wrote:
> > We should prefer `const struct pci_device_id` over
> > `DEFINE_PCI_DEVICE_TABLE` to meet kernel coding style guidelines.
> > This issue was reported by checkpatch.
> 
> Honestly, I prefer the macro -- it stands-out more.  Maybe the style
> guidelines and/or checkpatch should change instead?

The macro is horrid, no other bus has this type of thing just to save a
few characters in typing, so why should PCI be "special" in this regard
anymore?

thanks,

greg k-h
