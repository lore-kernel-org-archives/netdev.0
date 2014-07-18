From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH 0/25] Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 16:33:16 +0000
Message-ID: <1405701196.21801.3.camel@jekeller-desk1.amr.corp.intel.com>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
 <1405700934.605.31.camel@jarvis.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
 "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "benoit.taine@lip6.fr" <benoit.taine@lip6.fr>,
 "ath5k-devel@venema.h4ckr.net" <ath5k-devel@venema.h4ckr.net>,
 "linux-acenic@sunsite.dk" <linux-acenic@sunsite.dk>,
 "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
 "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
 "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
 "linux-hippi@sunsite.dk" <linux-hippi@sunsite.dk>,
 "industrypack-devel@lists.sourceforge.net"
 <industrypack-devel@lists.sourceforge.net>,
 "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
 "xen-devel@lists.xenproject.o
To: "James.Bottomley@HansenPartnership.com"
 <James.Bottomley@HansenPartnership.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1405700934.605.31.camel@jarvis.lan>
Content-Language: en-US
Content-ID: <CD9845FD8478314381700031D1A8C64A@intel.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-07-18 at 09:28 -0700, James Bottomley wrote:
> On Fri, 2014-07-18 at 17:26 +0200, Benoit Taine wrote:
> > We should prefer `const struct pci_device_id` over
> > `DEFINE_PCI_DEVICE_TABLE` to meet kernel coding style guidelines.
> > This issue was reported by checkpatch.
> 
> What kernel coding style?  checkpatch isn't the arbiter of style, if
> that's the only problem.
> 
> The DEFINE_PCI macro was a well reasoned addition when it was added in
> 2008.  The problem was most people were getting the definition wrong.
> When we converted away from CONFIG_HOTPLUG, having this DEFINE_ meant
> that only one place needed changing instead of hundreds for PCI tables.
> 
> The reason people were getting the PCI table wrong was mostly the init
> section specifiers which are now gone, but it has enough underlying
> utility (mostly constification) that I don't think we'd want to churn
> the kernel hugely to make a change to struct pci_table and then have to
> start detecting and fixing misuses.
> 
> James
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I would rather fix the misuses of the macro, than remove it. Could we
possibly make checkpatch smart enough to tell when the macro is misused?

Thanks,
Jake
