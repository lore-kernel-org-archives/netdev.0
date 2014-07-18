From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/25] Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 14:27:00 -0700
Message-ID: <20140718212700.GA12121@kroah.com>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
	<20140718162213.GC31114@tuxdriver.com>
	<20140718164340.GA24960@kroah.com>
	<1405702472.30262.1.camel@dabdike.int.hansenpartnership.com>
	<20140718181759.GB2193@kroah.com>
	<CAPM=9tzgWdnv7jc+xjsJUf0EcyGU+V7nFHzzQ16ui1eE0ihyQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org,
	Linux Fbdev development list <linux-fbdev@vger.kernel.org>,
	linux-pci@vger.kernel.org, dri-devel <dri-devel@lists.freedesktop.org>,
	virtualization@lists.linux-foundation.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Benoit Taine <benoit.taine@lip6.fr>,
	ath5k-devel@venema.h4ckr.net, linux-acenic@sunsite.dk,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	users@rt2x00.serialmonkey.com, linux-rdma@vger.kernel.org,
	ath10k@lists.infradead.org, linux-hippi@sunsite.dk,
	industrypack-devel@lists.sourceforge.net,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	xen-devel@lists.xenproject.org,
	MPT-FusionLinux.pdl@avagotech.com, ath9k-devel@venema.h4ckr.net,
	wil6210@qca.qualcomm.com, linux-pcmcia@lists.infradead.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-can@vger.kernel.org, platform-driver-x86@vger.kernel.org,
	Network D
To: Dave Airlie <airlied@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CAPM=9tzgWdnv7jc+xjsJUf0EcyGU+V7nFHzzQ16ui1eE0ihyQA@mail.gmail.com>
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

On Sat, Jul 19, 2014 at 07:14:12AM +1000, Dave Airlie wrote:
> >
> > We have almost 1000 more uses of the non-macro version than the "macro"
> > version in the kernel today:
> > $ git grep -w DEFINE_PCI_DEVICE_TABLE | wc -l
> > 262
> > $ git grep "const struct pci_device_id" | wc -l
> > 1254
> 
> did you check for non-const ones? just to see if we have any of the
> broken case in the tree :-)

I didn't :)

> as for consistency, pci_dev vs usb_device :-P

Read farther down the email...
