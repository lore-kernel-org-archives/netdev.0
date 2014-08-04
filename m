From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1] cris: fix %d confusingly prefixed with
 0x in format string
Date: Sun, 03 Aug 2014 17:33:45 -0700
Message-ID: <1407112425.16152.10.camel@joe-AO725>
References: <1407018043-648-1-git-send-email-hans@hanshq.net>
 <1407026806.1835.21.camel@joe-AO725> <53DD8E17.1@hanshq.net>
 <1407046215.1835.24.camel@joe-AO725> <53DED2E9.5090205@hanshq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel <devel@driverdev.osuosl.org>, linux-cifs@vger.kernel.org,
 alsa-devel@alsa-project.org, linux-cris-kernel@axis.com,
 netdev <netdev@vger.kernel.org>,
 kernel-janitors <kernel-janitors@vger.kernel.org>,
 linux-kernel@vger.kernel.org, starvik@axis.com
To: Hans Wennborg <hans@hanshq.net>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <53DED2E9.5090205@hanshq.net>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-08-03 at 17:25 -0700, Hans Wennborg wrote:
> On 08/02/2014 11:10 PM, Joe Perches wrote:
> > On Sat, 2014-08-02 at 18:19 -0700, Hans Wennborg wrote:
> >> Yes, I have a patch for a bunch of these, but I figured it would be
> >> easier to get it merged if I split it up. (Complete kernel newbie here.)
> >
> > You as a kernel newbie did good, thanks.
> >
> > A small tip would be to do all of them in a single series
> > cc'ing each individual patch to the appropriate maintainers
> > and mailing lists.
> 
> Thanks for the advice! I have split up and sent out the big patch as a 
> series, with hopefully the right folks CC'd.

Another nice thing to do is to use git format-patch --cover-letter
so that you can use a [PATCH 0/n] introductory description too.

Other than that, nice job, thanks.

Perhaps now you can do the "0x%u" variants.

$ /usr/bin/git grep -P '0x\%(?!ullx\b|ullX\b|llux\b|lux\b|ulx\b|ulX\b|lx\b|lluX\b|luX\b|lX\b)[ul]*[u]'
drivers/iommu/arm-smmu.c:                                   "Unexpected context fault (fsr 0x%u)\n",
drivers/net/vmxnet3/vmxnet3_drv.c:                              "txd[%u]: 0x%llu %u %u\n",
drivers/net/wireless/mwifiex/cfg80211.c:                wiphy_dbg(wiphy, "info: ongoing ROC, cookie = 0x%llu\n",
drivers/pinctrl/pinctrl-at91.c:         dev_dbg(dev, "pio%c%d configured as periph%c with conf = 0x%lu\n",
drivers/pinctrl/pinctrl-at91.c:         dev_dbg(dev, "pio%c%d configured as gpio with conf = 0x%lu\n",
drivers/scsi/cxgbi/libcxgbi.c:          "csk 0x%p,%u,0x%lu,%u, seq %u, wup %u, thre %u, %u.\n",
drivers/scsi/qla2xxx/qla_target.c:          "dif check TGT cdb 0x%x lba 0x%llu: [Actual|Expected] Ref Tag[0x%x|0x%x], App Tag [0x%x|0x%x], Guard [0x%x|0x%x]\n",
drivers/usb/musb/ux500_dma.c:           "packet_sz=%d, mode=%d, dma_addr=0x%llu, len=%d is_tx=%d\n",
fs/exofs/dir.c:         "offset=%lu, inode=0x%llu, rec_len=%d, name_len=%d\n",
fs/xfs/xfs_discard.c:    "discard failed for extent [0x%llu,%u], error %d",
sound/soc/atmel/atmel_ssc_dai.c:        pr_debug("atmel_ssc_startup: SSC_SR=0x%u\n",

There are some more with specific format lengths too:

arch/sparc/kernel/smp_32.c:             printk(KERN_NOTICE "No MID found for CPU%d at node 0x%08d", id, cpu_node);
drivers/mfd/rtsx_usb.c: dev_dbg(&intf->dev, "%s called with pm message 0x%04u\n",
drivers/net/wireless/rtlwifi/rtl8192de/fw.c:             "Polling FW ready fail!! REG_MCUFWDL:0x%08ul\n",
drivers/tty/moxa.c:                     printk(KERN_INFO "MOXA isa board found at 0x%.8lu and "

cheers, Joe
