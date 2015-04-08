From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 01/14] parport: return value of attach and
 parport_register_driver
Date: Wed, 8 Apr 2015 14:38:32 +0300
Message-ID: <20150408113832.GH10964@mwanda>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
 <1428492040-5581-2-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Rodolfo Giometti <giometti@enneenne.com>,
 linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Wolfram Sang <wsa@the-dreams.de>,
 Takashi Iwai <tiwai@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 alsa-devel@alsa-project.org, "James E.J. Bottomley" <JBottomley@parallels.com>,
 Jaroslav Kysela <perex@perex.cz>, Mark Brown <broonie@kernel.org>,
 linux-i2c@vger.kernel.org, Willy Tarreau <willy@meta-x.org>,
 linux-spi@vger.kernel.org, netdev@vger.kernel.org,
 Jean Delvare <jdelvare@suse.de>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1428492040-5581-2-git-send-email-sudipm.mukherjee@gmail.com>
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

1) We can't apply this patch on its own so this way of breaking up the
patches doesn't work.

2) I was thinking that all the ->attach() calls would have to succeed or
we would bail.  Having some of them succeed and some fail doesn't seem
like it will simplify the driver code very much.  But I can also see
your point.  Hm...

Minor comment:  No need to preserve the error code if there are lots
which we miss.  We may as well hard code an error code.  But that's a
minor thing.  Does this actually simplify the driver code?  That's the
more important thing.

regards,
dan carpenter
