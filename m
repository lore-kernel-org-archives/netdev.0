From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH 03/11] au1100fb: remove a bogus
 dma_free_nonconsistent call
Date: Tue, 20 Jun 2017 12:58:02 +0200
Message-ID: <2219033.M9DERpzktn@amdc3058>
References: <20170616071716.17321-1-hch@lst.de>
 <8727942.IUH8e0tH8t@amdc3058> <20170620091045.GA10272@lst.de>
 <CGME20170620105805epcas1p4ea41a72356c35f2a16197b970939fb65@epcas1p4.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev@vger.kernel.org, linux-scsi@vger.kernel.org,
 netdev@vger.kernel.org, alsa-devel@alsa-project.org,
 linux-kernel@vger.kernel.org, linux-serial@vger.kernel.org,
 nios2-dev@lists.rocketboards.org, linux-metag@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-reply-to: <20170620091045.GA10272@lst.de>
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

On Tuesday, June 20, 2017 11:10:45 AM Christoph Hellwig wrote:
> On Mon, Jun 19, 2017 at 01:15:04PM +0200, Bartlomiej Zolnierkiewicz wrote:
> > On Friday, June 16, 2017 09:17:08 AM Christoph Hellwig wrote:
> > > au1100fb is using managed dma allocations, so it doesn't need to
> > > explicitly free the dma memory in the error path (and if it did
> > > it would have to use the managed version).
> > > 
> > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > 
> > Acked-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> 
> Are you fine with picking this up through the new dma-mapping tree?

Yes, this is why Ack-ed it.

If you prefer me to merge it through fbdev for 4.13 please let me know.

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung R&D Institute Poland
Samsung Electronics
