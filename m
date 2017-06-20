From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 03/11] au1100fb: remove a bogus
	dma_free_nonconsistent	call
Date: Tue, 20 Jun 2017 11:10:45 +0200
Message-ID: <20170620091045.GA10272@lst.de>
References: <20170616071716.17321-1-hch@lst.de>
 <20170616071716.17321-4-hch@lst.de>
 <CGME20170619111507epcas5p47fd18b90a02d827da256ff4ebbda8089@epcas5p4.samsung.com>
 <8727942.IUH8e0tH8t@amdc3058>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev@vger.kernel.org, linux-scsi@vger.kernel.org,
 netdev@vger.kernel.org, alsa-devel@alsa-project.org,
 Christoph Hellwig <hch@lst.de>, linux-serial@vger.kernel.org,
 nios2-dev@lists.rocketboards.org, linux-metag@vger.kernel.org,
 linux-kernel@vger.kernel.org
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
Content-Disposition: inline
In-Reply-To: <8727942.IUH8e0tH8t@amdc3058>
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

On Mon, Jun 19, 2017 at 01:15:04PM +0200, Bartlomiej Zolnierkiewicz wrote:
> On Friday, June 16, 2017 09:17:08 AM Christoph Hellwig wrote:
> > au1100fb is using managed dma allocations, so it doesn't need to
> > explicitly free the dma memory in the error path (and if it did
> > it would have to use the managed version).
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Acked-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Are you fine with picking this up through the new dma-mapping tree?
