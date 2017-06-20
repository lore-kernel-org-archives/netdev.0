From: David Laight <David.Laight@ACULAB.COM>
Subject: Re: remove dma_alloc_noncoherent
Date: Tue, 20 Jun 2017 12:44:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0026C08@AcuExch.aculab.com>
References: <20170616071716.17321-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Christoph Hellwig' <hch@lst.de>, "linux-scsi@vger.kernel.org"
 <linux-scsi@vger.kernel.org>, "linux-serial@vger.kernel.org"
 <linux-serial@vger.kernel.org>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "linux-metag@vger.kernel.org"
 <linux-metag@vger.kernel.org>, "nios2-dev@lists.rocketboards.org"
 <nios2-dev@lists.rocketboards.org>, "linux-fbdev@vger.kernel.org"
 <linux-fbdev@vger.kernel.org>, "alsa-devel@alsa-project.org"
 <alsa-devel@alsa-project.org>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20170616071716.17321-1-hch@lst.de>
Content-Language: en-US
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

From: Christoph Hellwig
> Sent: 16 June 2017 08:17
>
> For many years we've had the dma_alloc_attrs API that is more flexible
> than dma_alloc_noncoherent.  This series moves the remaining users over
> to the attrs API.

And most of the callers probably only want to specify 'noncoherent'.
Grepping the source for other uses is easier if the wrapper is left.

	David
