From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH 12/14] i2c-parport: return proper error values from attach
Date: Fri, 10 Apr 2015 10:35:43 +0530
Message-ID: <20150410050543.GA3561@sudip-PC>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
 <1428492040-5581-13-git-send-email-sudipm.mukherjee@gmail.com>
 <20150409071307.GA1166@katana>
 <20150409113342.5621af83@endymion.delvare>
 <20150409102528.GC1166@katana>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Rodolfo Giometti <giometti@enneenne.com>,
 linux-scsi@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Takashi Iwai <tiwai@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 linux-kernel@vger.kernel.org,
 "James E.J. Bottomley" <JBottomley@parallels.com>,
 Jaroslav Kysela <perex@perex.cz>, alsa-devel@alsa-project.org,
 Mark Brown <broonie@kernel.org>, linux-i2c@vger.kernel.org,
 Willy Tarreau <willy@meta-x.org>, linux-spi@vger.kernel.org,
 netdev@vger.kernel.org, Jean Delvare <jdelvare@suse.de>
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20150409102528.GC1166@katana>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Thu, Apr 09, 2015 at 12:25:28PM +0200, Wolfram Sang wrote:
> 
> > It doesn't really matter that the error codes are different, it matters
> > that they are meaningful. As much as possible you should pass error
> > codes from the lower layers. parport_claim_or_block() and
> > i2c_bit_add_bus() return proper error codes so you should record and
> > transmit them.
> 
> Oh, surely yes. I assumed they don't and this series is a first step to
> fix this. Should have looked myself. Thanks for jumping in here.
> 
I planned this series to be the first step to fix the attach function
which does not return it succeeded or failed. And if attach has failed
then there is no reason that module_init will report success.

But as Greg pointed out that the first step should be to bring the
parallel port in the driver model. I am working on that now, I will
post a v2 of this series once that modification is done, and that will
need extensive testing.

regards
sudip
