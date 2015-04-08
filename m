From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 01/14] parport: return value of attach and
 parport_register_driver
Date: Wed, 8 Apr 2015 19:56:00 +0200
Message-ID: <20150408175600.GI18177@1wt.eu>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
 <1428492040-5581-2-git-send-email-sudipm.mukherjee@gmail.com>
 <20150408113832.GH10964@mwanda> <20150408115010.GA11153@sudip-PC>
 <20150408122737.GK10964@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Rodolfo Giometti <giometti@enneenne.com>,
 linux-scsi@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Wolfram Sang <wsa@the-dreams.de>, Takashi Iwai <tiwai@suse.de>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-spi@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 "James E.J. Bottomley" <JBottomley@parallels.com>,
 Jaroslav Kysela <perex@perex.cz>, Mark Brown <broonie@kernel.org>,
 linux-i2c@vger.kernel.org, netdev@vger.kernel.org, alsa-devel@alsa-project.org,
 Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Jean Delvare <jdelvare@suse.de>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20150408122737.GK10964@mwanda>
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

On Wed, Apr 08, 2015 at 03:27:37PM +0300, Dan Carpenter wrote:
> On Wed, Apr 08, 2015 at 05:20:10PM +0530, Sudip Mukherjee wrote:
> > On Wed, Apr 08, 2015 at 02:38:32PM +0300, Dan Carpenter wrote:
> > > 1) We can't apply this patch on its own so this way of breaking up the
> > > patches doesn't work.
> > yes, if the first patch is reverted for any reason all the others need
> > to be reverted also. so then everything in one single patch?
> 
> The problem is that patch 1/1 breaks the build.  The rule is that we
> should be able to apply part of a patch series and nothing breaks.  If
> we apply the patch series out of order than things break that's our
> problem, yes.  But if we apply only 1/1 and it breaks, that's a problem
> with the series.

Yep, keep in mind that "git bisect" will randomly land in the middle of
any set of patches during a debugging session and it could very well land
on this one. If it breaks, that's a real pain for the people trying to
bisect their bug because suddenly they have to deal with a second bug
totally different from theirs.

Regards,
Willy
